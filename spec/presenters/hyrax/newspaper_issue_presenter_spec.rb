require 'spec_helper'
RSpec.describe Hyrax::NewspaperIssuePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:volume).to(:solr_document) }
  it { is_expected.to delegate_method(:edition).to(:solr_document) }
  it { is_expected.to delegate_method(:issue_number).to(:solr_document) }
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
end