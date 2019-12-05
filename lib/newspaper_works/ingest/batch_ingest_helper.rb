require 'find'

module NewspaperWorks
  module Ingest
    # mixin module for common batch ingest steps
    #
    # Presumed contract for consuming class:
    # - Has accessors for path, lccn, publication, opts
    module BatchIngestHelper
      def detect_media(path)
        result = 'pdf' # default
        Find.find(path) do |p|
          result = 'image' if p.end_with?('jp2') || /TIF[F]?$/i.match(p)
        end
        result
      end

      def lccn_from_path(path)
        File.basename(path)
      end

      def normalize_lccn(v)
        p = /^[A-Za-z]{0,3}[0-9]{8}([0-9]{2})?$/
        v = v.gsub(/\s+/, '').downcase.slice(0, 13)
        raise ArgumentError, "LCCN appears invalid: #{v}" unless p.match(v)
        v
      end

      def issue_title(issue_data)
        issue_data.title
      end

      def copy_issue_metadata(source, target)
        target.title = issue_title(source)
        target.lccn = source.lccn
        target.publication_date = source.publication_date
        target.edition_number = source.edition_number
      end

      def attach_file(work, path)
        attachment = NewspaperWorks::Data::WorkFiles.of(work)
        attachment.assign(path)
        attachment.commit!
      end

      def link_publication(issue)
        find_or_create_publication_for_issue(
          issue,
          lccn,
          publication.title,
          opts
        )
      end

      def create_issue(issue_data)
        issue = NewspaperIssue.create
        copy_issue_metadata(issue_data, issue)
        NewspaperWorks::Ingest.assign_administrative_metadata(issue, opts)
        issue.save!
        write_log(
          "Created new NewspaperIssue work with date, lccn, edition metadata:"\
          "\n"\
          "\tLCCN: #{lccn}\n"\
          "\tPublication Date: #{issue_data.publication_date}\n"\
          "\tEdition number: #{issue_data.edition_number}"
        )
        link_publication(issue)
        issue
      end

      def ingest_pdf(issue, path)
        # ingest primary PDF for issue:
        attach_file(issue, path)
        # queue page creation job:
        CreateIssuePagesJob.perform_later(issue, [path], nil, nil)
      end

      def create_page(page_image, issue)
        page = NewspaperPage.create
        page.title = page_image.title
        page.page_number = page_image.page_number
        page.save!
        # Link page as a child of issue, via ordered members:
        issue.ordered_members << page
        NewspaperWorks::Ingest.assign_administrative_metadata(page, opts)
        issue.save!
        # Ensure we have a source TIFF file, attach to page:
        path = page_image.path
        path = page_image.path.end_with?('jp2') ? make_tiff(path) : path
        attach_file(page, path)
      end

      def ingest_pages(issue, issue_data)
        # Create pages in order they appear (lexical)
        issue_data.each_value { |page_image| create_page(page_image, issue) }
        # Make an issue PDF from constituent pages, via retryable async job,
        #   which will not succeed until the PDF derivatives are created
        #   for each page, but should eventually succeed on that condition:
        NewspaperWorks::ComposeIssuePDFJob.perform_later(issue)
      end

      def make_tiff(path)
        raise ArgumentError unless path.end_with?('jp2')
        Hyrax.config.whitelisted_ingest_dirs |= [Dir.tmpdir]
        name = File.basename(path).split('.')[0]
        # OpenJPEG2000 has weird quirk, only likes 3-char file ext TIF:
        tiff_path = File.join(Dir.mktmpdir, "#{name}.tif")
        cmd = "opj_decompress -i #{path} -o #{tiff_path}"
        Open3.popen3(cmd) do |_stdin, _stdout, stderr, _wait_thr|
          unless stderr.read.strip.empty?
            msg = "Error converting JP2 to TIFF: #{path}"
            write_log(msg, Logger::ERROR)
            raise msg
          end
        end
        tiff_path
      end
    end
  end
end
