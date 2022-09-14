require 'open3'
require 'tmpdir'

module NewspaperWorks
  module Ingest
    class BatchIssueIngester
      # CLI constructor, related class methods:
      extend NewspaperWorks::Ingest::FromCommand

      include NewspaperWorks::Ingest::PubFinder
      include NewspaperWorks::Ingest::BatchIngestHelper
      include NewspaperWorks::Logging

      attr_accessor :path, :lccn, :publication, :opts, :issues

      def initialize(path, opts = {})
        @path = path
        lccn = opts[:lccn] || lccn_from_path(path)
        @lccn = normalize_lccn(lccn)
        # get publication info for LCCN from authority web service:
        @publication = NewspaperWorks::Ingest::PublicationInfo.new(@lccn)
        # issues for publication, as enumerable of PDFIssue
        @issues = issue_enumerator(publication: publication, path: path)
        @opts = opts
        configure_logger('ingest')
      end

      TACTIC_ISSUE_PDF = :issue_pdf
      TACTIC_PAGE_IMAGE = :page_image

      def ingest
        tactic = ingest_type
        write_log("Beginning issue(s) batch ingest for #{@path}")
        write_log("\tPublication: #{@publication.title} (LCCN: #{@lccn})")
        @issues.each do |path, issue_data|
          issue = create_issue(issue_data)
          ingest_pdf(issue, path) if tactic == TACTIC_ISSUE_PDF
          ingest_pages(issue, issue_data) if tactic = TACTIC_PAGE_IMAGE
        end
        write_log(
          "Issue ingest completed for LCCN #{@lccn}. Asyncrhonous jobs "\
          "may still be creating derivatives for issue, and child page works."
        )
      end

      private

      # @see NewspaperWorks::Ingest::BatchIngestHelper for the default media assumption.
      def issue_enumerator(publication:, path:)
        impl = NewspaperWorks::Ingest::PDFIssues
        impl = NewspaperWorks::Ingest::ImageIngestIssues if detect_media(path) == NewspaperWorks::Ingest::BatchIngestHelper::MEDIA_IMAGE
        # issue enumerator depends on detected media:
        impl.new(path, publication)
      end

      def link_publication(issue)
        find_or_create_publication_for_issue(
          issue,
          @lccn,
          @publication.title,
          @opts
        )
      end

      def create_issue(issue_data)
        # NOTE: Do we need to `.create` or can we do `.new` ?  With `.create`
        issue = NewspaperIssue.create
        copy_issue_metadata(issue_data, issue)
        NewspaperWorks::Ingest.assign_administrative_metadata(issue, @opts)
        issue.save!
        write_log(
          "Created new NewspaperIssue work with date, lccn, edition metadata:"\
          "\n"\
          "\tLCCN: #{@lccn}\n"\
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
        # NOTE: Should there be a depositor and admin_set? (e.g. the 3rd and 4th parameter)
        CreateIssuePagesJob.perform_later(issue, [path], nil, nil)
      end

      def create_page(page_image, issue)
        # NOTE: Do we need to `.create` or can we do `.new` ?  With `.create`
        page = NewspaperPage.create
        page.title = page_image.title
        page.page_number = page_image.page_number
        page.save!
        # Link page as a child of issue, via ordered members:
        issue.ordered_members << page
        NewspaperWorks::Ingest.assign_administrative_metadata(page, @opts)
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

      def ingest_type
        return TACTIC_ISSUE_PDF if @issues.class == NewspaperWorks::Ingest::PDFIssues
        TACTIC_PAGE_IMAGE
      end
    end
  end
end
