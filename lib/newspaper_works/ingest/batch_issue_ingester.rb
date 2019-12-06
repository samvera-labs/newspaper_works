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
        # issues for publication, as ordered enumerable object representing
        #   issue, that (a) has metadata for issue; (b) enumerates pages.
        @issues = issue_enumerator
        @opts = opts
        configure_logger('ingest')
      end

      def issue_enumerator
        impl = NewspaperWorks::Ingest::PDFIssues
        impl = NewspaperWorks::Ingest::ImageIngestIssues if detect_media(path) == 'image'
        # issue enumerator depends on detected media:
        impl.new(path, publication)
      end

      def ingest_type
        return 'issue_pdf' if @issues.class == NewspaperWorks::Ingest::PDFIssues
        'page_image'
      end

      def ingest
        write_log("Beginning issue(s) batch ingest for #{path}")
        write_log("\tPublication: #{publication.title} (LCCN: #{lccn})")
        @issues.each do |path, issue_data|
          issue = create_issue(issue_data)
          tactic = ingest_type
          ingest_pdf(issue, path) if tactic == 'issue_pdf'
          ingest_pages(issue, issue_data) if tactic == 'page_image'
        end
        write_log(
          "Issue ingest completed for LCCN #{lccn}. Asyncrhonous jobs "\
          "may still be creating derivatives for issue, and child page works."
        )
      end
    end
  end
end
