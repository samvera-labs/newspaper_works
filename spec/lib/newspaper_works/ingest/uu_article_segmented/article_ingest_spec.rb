require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::UUArticleSegmented::ArticleIngest do
  include_context 'ingest test fixtures'

  let(:dnews) { File.join(article_segmented, 'batch_deseret_news') }

  let(:article_path) { File.join(dnews, 'articles', '1.xml') }

  let(:issue_path) { File.join(dnews, 'unit.xml') }

  let(:article) { described_class.new(article_path) }

  describe "construction and access" do
    it "constructs adapter given path" do
      expect(article.path).to eq article_path
      expect(article.doc).to be_a Nokogiri::XML::Document
    end

    it "constructs adapter with optional issue context" do
      issue = double("issue")
      article = described_class.new(article_path, issue)
      expect(article.issue).to be issue
      expect(article.issue_path).to eq issue_path
    end

    it "provides date metadata for page" do
      expect(article.publication_date).to eq '1850-06-15'
    end
  end

  describe "image and text access" do
    it "provides valid image path" do
      expect(File.exist?(article.image_path)).to be true
    end

    it "provides page text tokens" do
      text = article.text
      expect(text).to be_a String
      expect(text.size).to be > 0
    end
  end
end
