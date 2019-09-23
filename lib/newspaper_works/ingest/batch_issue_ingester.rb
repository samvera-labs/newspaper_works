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
        lccn = opts[:lccn]
        @lccn = normalize_lccn(lccn.nil? ? lccn_from_path(path) : lccn)
        # get publication info for LCCN from authority web service:
        @publication = NewspaperWorks::Ingest::PublicationInfo.new(@lccn)
        # issues for publication, as enumerable of PDFIssue
        @issues = issue_enumerator
        @opts = opts
        configure_logger('ingest')
      end

      def issue_enumerator
        # TODO: pivot which enumerator to return based on detected contents:
        NewspaperWorks::Ingest::PDFIssues.new(path, publication)
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
        CreateIssuePagesJob.perform_later(issue, [path], nil, nil)
      end

      def ingest_pages(issue, issue_data)
        issue_data.each do |page_image|
          # NewspaperPage is created, with
          page = NewspaperPage.create
          page.title = page_image.title
          page.page_nummber = page_image.page_number
          page.save!
          # Link page as a child of issue, via ordered members:
          issue.ordered_members << page
          issue.save!
          # Ensure we have a source TIFF file, attach to page:
          path = page_image.path
          path = page_image.path.end_with?('jp2') ? mk_tiff(path) : path
          attach_file(page, path)
          # Make an issue PDF from constituent pages, via retryable async job,
          #   which will not succeed until the PDF derivatives are created
          #   for each page, but should eventually succeed on that condition:
        end
        NewspaperWorks::ComposeIssuePDFJob.perform_later(issue)
      end

      def make_tiff(path)
        raise ArgumentError unless path.end_with?('jp2')
        name = File.basename(path).split('.')[0]
        tiff_path = File.join(Dir.tmpdir, "#{name}.tiff")
        cmd = "opj_decompress -i #{path} -o #{tiff_path}"
        Open3.popen3(cmd) do |_stdin, _stdout, stderr, _wait_thr|
          raise 'Error converting JP2 to TIFF' unless stderr.read.empty?
        end
        tiff_path
      end

      def ingest
        write_log("Beginning issue(s) batch ingest for #{@path}")
        write_log("\tPublication: #{@publication.title} (LCCN: #{@lccn})")
        @issues.each do |path, issue_data|
          issue = create_issue(issue_data)
          ingest_pdf(issue, path)
        end
        write_log(
          "Issue ingest completed for LCCN #{@lccn}. Asyncrhonous jobs "\
          "may still be creating derivatives for issue, and child page works."
        )
      end
    end
  end
end
