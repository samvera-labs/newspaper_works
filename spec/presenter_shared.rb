# Shared presenter attributes
RSpec.shared_examples "a newspaper core presenter" do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org') }
  let(:user_key) { 'a_user_key' }

  let(:core_attributes) do
    { "alternative_title" => ['There and Back Again'],
      "genre" => ['newspaper'],
      "issn" => '2049-3630',
      "lccn" => '2001001114',
      "oclcnum" => 'ocm00012345',
      "held_by" => 'Marriott Library' }
  end

  let(:ability) { nil }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  it { is_expected.to delegate_method(:alternative_title).to(:solr_document) }
  it { is_expected.to delegate_method(:genre).to(:solr_document) }
  it { is_expected.to delegate_method(:issn).to(:solr_document) }
  it { is_expected.to delegate_method(:lccn).to(:solr_document) }
  it { is_expected.to delegate_method(:oclcnum).to(:solr_document) }
  it { is_expected.to delegate_method(:held_by).to(:solr_document) }
end

RSpec.shared_examples "a scanned media presenter" do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org') }
  let(:user_key) { 'a_user_key' }

  let(:scanned_media_attributes) do
    { "text_direction" => 'left',
      "page_number" => '5',
      "section" => '1' }
  end

  let(:ability) { nil }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  it { is_expected.to delegate_method(:text_direction).to(:solr_document) }
  it { is_expected.to delegate_method(:page_number).to(:solr_document) }
  it { is_expected.to delegate_method(:section).to(:solr_document) }
end
