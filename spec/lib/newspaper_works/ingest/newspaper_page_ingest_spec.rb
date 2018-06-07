require 'spec_helper'

# test NewspaperPageIngest against work
RSpec.describe NewspaperWorks::Ingest::NewspaperPageIngest do
  # define the path to the file we will use for multiple examples
  let(:path) do
    fixtures = File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files')
    File.join(fixtures, 'page1.tiff')
  end

  it_behaves_like('ingest adapter IO')

  describe "file import and attachment" do
    it "ingests file data and saves" do
      adapter = build(:newspaper_page_ingest)
      adapter.ingest(path)
    end
  end
end
