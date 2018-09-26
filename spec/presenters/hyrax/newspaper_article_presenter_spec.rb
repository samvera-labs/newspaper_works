require 'spec_helper'
RSpec.describe Hyrax::NewspaperArticlePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org') }
  let(:user_key) { 'a_user_key' }

  let(:attributes) do
    { "author" => '888888',
      "photographer" => ['foo', 'bar'],
      "volume" => ["volume 1"],
      "edition" => ["1st"],
      "issue_number" => ['1'],
      "geographic_coverage" => ["wide"],
      "extent" => ["vast"],
      "publication_date" => ["2017-08-25"] }
  end
  let(:ability) { nil }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:author).to(:solr_document) }
  it { is_expected.to delegate_method(:photographer).to(:solr_document) }
  it { is_expected.to delegate_method(:volume).to(:solr_document) }
  it { is_expected.to delegate_method(:edition).to(:solr_document) }
  it { is_expected.to delegate_method(:issue_number).to(:solr_document) }
  it { is_expected.to delegate_method(:geographic_coverage).to(:solr_document) }
  it { is_expected.to delegate_method(:extent).to(:solr_document) }
  it { is_expected.to delegate_method(:publication_date).to(:solr_document) }

  # newspaper_core_presenter
  it { is_expected.to delegate_method(:alternative_title).to(:solr_document) }
  it { is_expected.to delegate_method(:genre).to(:solr_document) }
  it { is_expected.to delegate_method(:place_of_publication).to(:solr_document) }
  it { is_expected.to delegate_method(:issn).to(:solr_document) }
  it { is_expected.to delegate_method(:lccn).to(:solr_document) }
  it { is_expected.to delegate_method(:oclcnum).to(:solr_document) }
  it { is_expected.to delegate_method(:held_by).to(:solr_document) }

  # scanned_media_presenter
  it { is_expected.to delegate_method(:text_direction).to(:solr_document) }
  it { is_expected.to delegate_method(:page_number).to(:solr_document) }
  it { is_expected.to delegate_method(:section).to(:solr_document) }
end
