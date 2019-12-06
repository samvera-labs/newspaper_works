require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::UUArticleSegmented::IssueArticles do
  include_context 'ingest test fixtures'

  let(:dnews) { File.join(article_segmented, 'batch_deseret_news') }

  let(:page_path) { File.join(dnews, 'pages', 'p008_Va_071_D45_v01.xml') }

  let(:article_path) { File.join(dnews, 'articles', '1.xml') }

  let(:issue_path) { File.join(dnews, 'unit.xml') }

  let(:issue) do
    NewspaperWorks::Ingest::UUArticleSegmented::IssueIngest.new(
      issue_path
    )
  end

  let(:articles) { described_class.new(issue_path, issue) }

  let(:article_cls) do
    NewspaperWorks::Ingest::UUArticleSegmented::ArticleIngest
  end

  describe "construction and composition" do
    it "constructs adapter given path" do
      expect(issue.path).to eq issue_path
      expect(issue.doc).to be_a Nokogiri::XML::Document
    end
  end

  describe "enumeration of articles" do
    it "acts like a hash of page path keys, page values" do
      expect(articles.keys).to include article_path
      expect(articles.size).to eq 18
      expect(articles.size).to eq articles.keys.size
      # get value either by [] or by info method:
      article = articles.info(article_path)
      expect(article).to be_a article_cls
      # [] == #info, no duplicate construction of child pages (via memoization):
      article_again = articles[article_path]
      expect(article_again).to be article
      # article has reference to parent issue:
      expect(articles.issue).to be issue
      expect(article.issue).to be issue
    end
  end
end
