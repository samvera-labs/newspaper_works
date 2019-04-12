require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::PageIngester do
  include_context "ndnp fixture setup"

  # use FactoryBot issue factory for a NewspaperIssue object for page:
  let(:issue) { create(:newspaper_issue) }

  # We need page source data as PageIngest
  let(:page_data) do
    NewspaperWorks::Ingest::NDNP::PageIngest.new(issue1, 'pageModsBib8')
  end

  let(:metadata) { page_data.metadata }

  # PageIngester adapter does the work we are testing:
  let(:adapter) { described_class.new(page_data, issue) }

  describe "adapter and asset construction" do
    it "constructs adapter with page source, issue context" do
      expect(adapter.page).to be page_data
      expect(adapter.issue).to be issue
      expect(adapter.path).to eq page_data.path
    end

    it "constructs NewspaperPage with adapter" do
      # construct_page is ingest of metadata only, without importing files:
      adapter.construct_page
      page = adapter.target
      expect(page).to be_a NewspaperPage
      expect(page.id).not_to be_nil
      expect(issue.members).to include page
    end
  end

  describe "metadata access/setting" do
    let(:expected_title) do
      "#{issue.title.first}: Page #{metadata.page_number}"
    end

    it "copies metadata to NewspaperPage" do
      adapter.construct_page
      page = adapter.target
      expect(page.title).to contain_exactly expected_title
      expect(page.width).to eq metadata.width
      expect(page.height).to eq metadata.height
      expect(page.identifier).to contain_exactly metadata.identifier
    end
  end

  describe "file import integration" do
    do_now_jobs = [IngestLocalFileJob, IngestJob, InheritPermissionsJob]

    it "attaches primary, derivative files", perform_enqueued: do_now_jobs do
      adapter.ingest
      page = adapter.target
      fileset = page.members.select { |m| m.class == FileSet }[0]
      # Reload fileset because jobs have modified:
      fileset.reload
      expect(fileset).not_to be_nil
      expect(fileset.original_file).not_to be_nil
      expect(fileset.original_file.mime_type).to eq 'image/tiff'
      derivatives = NewspaperWorks::Data::WorkDerivatives.new(page, fileset)
      expect(derivatives.keys).to match_array ["jp2", "xml", "pdf"]
    end
  end
end
