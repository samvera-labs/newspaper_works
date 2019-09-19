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
      issue.entries.each do |key, value|
        expect(value).to be_a NewspaperWorks::Ingest::PageImage
        expect(value.lccn).to eq publication.lccn
        expect(value.path).to eq key
        expect(value.issue).to be issue
      end
    end
  end
end
