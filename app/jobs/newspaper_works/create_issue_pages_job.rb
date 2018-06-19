module NewspaperWorks
  # Create child page works for issue
  class CreateIssuePagesJob < NewspaperWorks::ApplicationJob
    def perform(work, pdf_paths, user)
      # we will need depositor set on work, if it is nil
      work.depositor ||= user
      # create child pages for each page within each PDF uploaded:
      pdf_paths.each do |path|
        adapter = NewspaperWorks::Ingest::NewspaperIssueIngest.new(work)
        adapter.load(path)
        adapter.create_child_pages
      end
    end
  end
end
