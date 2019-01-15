# hyrax/spec/views/hyrax/base/_attribute_rows.html.erb_spec.rb
RSpec.describe 'newspaper_works/base/_attribute_rows.html.erb', type: :view do
  let(:url) { "http://example.com" }
  let(:title) { "There and Back Again" }
  let(:rights_statement_uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:ability) { double }
  let(:work) do
    stub_model(NewspaperArticle,
               title: [title],
               related_url: [url],
               rights_statement: [rights_statement_uri])
  end
  let(:solr_document) do
    SolrDocument.new(has_model_ssim: 'NewspaperArticle',
                     title_tesim: [title],
                     rights_statement_tesim: [rights_statement_uri],
                     related_url_tesim: [url])
  end

  let(:presenter) { Hyrax::NewspaperArticlePresenter.new(solr_document, ability) }

  let(:page) do
    render 'newspaper_works/base/attribute_rows', presenter: presenter
    Capybara::Node::Simple.new(rendered)
  end

  it 'shows rights statement with link to statement URL' do
    expect(page).to have_link("In Copyright", href: rights_statement_uri)
  end
end
