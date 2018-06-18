module NewspaperWorks
  module Ingest
    class NewspaperIssueIngest < BaseIngest
      def import
        # first, handle the PDF itself on the issue...
        super
        # ...then create child works from split pages
        create_child_pages
      end

      # Creates child pages with attached TIFF masters, can be called by
      #   `import`, or independently if `load` is called first.  The
      #   latter is appropriate if framework is already handling the
      #   NewspaperIssue file attachment (e.g. Hyrax upload via browser).
      def create_child_pages
        pages = NewspaperWorks::Ingest::PdfPages.new(path).to_a
        pages.each_with_index do |tiffpath, idx|
          page = new_child_page_with_file(tiffpath, idx)
          @work.members.push(page)
        end
        @work.save!(validate: false) unless pages.empty?
      end

      def new_child_page_with_file(tiffpath, idx)
        page = NewspaperPage.new
        page.title = [format("Page %<pagenum>i", pagenum: idx + 1)]
        page.depositor = @work.depositor
        page.save!
        NewspaperPageIngest.new(page).ingest(tiffpath)
        page
      end
    end
  end
end
