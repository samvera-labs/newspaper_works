require 'spec_helper'
require 'presenter_shared'

RSpec.describe Hyrax::NewspaperIssuePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org') }
  let(:user_key) { 'a_user_key' }

  let(:attributes) do
    { "volume" => '888888',
      "edition" => '1st issue',
      "issue_number" => ['1st issue'],
      "extent" => ["1st"],
      "publication_date" => ["2017-08-25"] }
  end

  it_behaves_like "a newspaper core presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:volume).to(:solr_document) }
  it { is_expected.to delegate_method(:edition).to(:solr_document) }
  it { is_expected.to delegate_method(:issue_number).to(:solr_document) }
  it { is_expected.to delegate_method(:extent).to(:solr_document) }
  it { is_expected.to delegate_method(:publication_date).to(:solr_document) }
end
