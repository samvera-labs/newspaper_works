require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::IssueImages do
  include_context 'ingest test fixtures'

  let(:lccn) { 'sn93059126' }

  let(:issue_path) { File.join(image_fixtures, lccn, '1853060401') }

  let(:publication) { NewspaperWorks::Ingest::PublicationInfo.new(lccn) }

  describe "issue construction and metadata" do
    it "constructs with path and publication" do
      issue = described_class.new(issue_path, publication)
      expect(issue.path).to eq issue_path
      expect(issue.filename).to eq File.basename(issue_path)
      expect(issue.publication).to be publication
      expect(issue.lccn).to eq lccn
      expect(issue.publication.lccn).to eq lccn
    end

    it "extracts date, edition, title from filename" do
      issue = described_class.new(issue_path, publication)
      expect(issue.publication_date).to eq '1853-06-04'
      expect(issue.edition_number).to eq 1
      expect(issue.title).to contain_exactly 'The weekly journal: June 4, 1853'
    end

    it "enumerates pages" do
      issue = described_class.new(issue_path, publication)
      expect(issue.to_a.size).to eq 4
      expect(issue.keys.size).to eq 4
      # lexical ordering:
      expect(issue.keys).to eq issue.keys.sort
      issue.entries.each_with_index do |pair, idx|
        # PageImage object value:
        page_image = pair[1]
        expect(page_image).to be_a NewspaperWorks::Ingest::PageImage
        expect(page_image.lccn).to eq publication.lccn
        # path key
        expect(page_image.path).to eq pair[0]
        expect(page_image.issue).to be issue
        # Verify lexical ordering (for page_number in file name vs. seq num):
        expect(page_image.page_number.to_i).to eq idx + 1
        # page numbering matches sequence numbering:
        expected_title = "The weekly journal: June 4, 1853: Page #{page_image.page_number}"
        expect(page_image.title).to contain_exactly expected_title
      end
    end
  end
end
