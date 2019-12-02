require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::UUArticleSegmented::PageIngest do
  include_context 'ingest test fixtures'

  let(:dnews) { File.join(article_segmented, 'batch_deseret_news') }

  let(:page_path) { File.join(dnews, 'pages', 'p008_Va_071_D45_v01.xml') }

  let(:issue_path) { File.join(dnews, 'unit.xml') }

  let(:page) { described_class.new(page_path) }

  describe "construction and composition" do
    it "constructs adapter given path" do
      expect(page.path).to eq page_path
      expect(page.doc).to be_a Nokogiri::XML::Document
    end

    it "constructs adapter with optional issue context" do
      issue = double("issue")
      page = described_class.new(page_path, issue)
      expect(page.issue).to be issue
      expect(page.issue_path).to eq issue_path
    end

    it "provides date metadata for page" do
      expect(page.publication_date).to eq '1850-06-15'
    end
  end

  describe "image and text access" do
    it "provides valid image path" do
      expect(File.exist?(page.image_path)).to be true
    end

    it "provides page text tokens" do
      text = page.text
      expect(text).to be_a String
      expect(text.size).to be > 0
    end
  end
end
