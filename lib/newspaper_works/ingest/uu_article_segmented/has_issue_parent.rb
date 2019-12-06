module NewspaperWorks
  module Ingest
    module UUArticleSegmented
      module HasIssueParent
        def issue_path
          path = File.expand_path('../unit.xml', File.dirname(@path))
          raise IOError, 'Manifest not found: #{path}' unless File.exist?(path)
          path
        end

        # Get issue for page/article, don't construct more than once (to access
        #   identical issue object on each call).
        # Access to related pages is through issue, to ensure pages are
        #   not duplicated.
        # @return [NewspaperWorks::Ingest::UUArticleSegmented::IssueIngest]
        def issue
          return @issue unless @issue.nil?
          @issue = IssueIngest.new(issue_path, self)
        end
      end
    end
  end
end
