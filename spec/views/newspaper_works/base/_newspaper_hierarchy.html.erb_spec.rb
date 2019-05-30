require 'spec_helper'
RSpec.describe 'newspaper_works/base/_newspaper_hierarchy.html.erb', type: :view do
  let(:url) { "http://example.com" }
  let(:title) { "There and Back Again" }
  let(:issn) { "2049-3630" }
  let(:place_of_publication_label) { "Salt Lake City, Utah, United States" }
  let(:publication_date) { "2019-01-24" }
  let(:rights_statement_uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:ability) { double }
  let(:request) { double(host: 'example.org') }

  let(:solr_document) do
    SolrDocument.new(has_model_ssim: 'NewspaperIssue',
                     title_tesim: [title],
                     issn_tesim: [issn],
                     place_of_publication_label_tesim: [place_of_publication_label],
                     publication_date_dtsim: [publication_date],
                     rights_statement_tesim: [rights_statement_uri],
                     related_url_tesim: [url],
                     publication_unique_id_ssi: 'sn1234567')
  end

  let(:presenter) { Hyrax::NewspaperIssuePresenter.new(solr_document, ability, request) }

  xit 'displays breadcrumbs' do
    render partial: "newspaper_hierarchy.html.erb", locals: { presenter: presenter }
    expect(rendered).to have_content 'ol'
  end
end
