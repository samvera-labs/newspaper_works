require 'spec_helper'
RSpec.describe Hyrax::NewspaperPagePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }

  let(:attributes) do
    { "height" => "1000px",
      "width" => "800px" }
  end

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:height).to(:solr_document) }
  it { is_expected.to delegate_method(:width).to(:solr_document) }

  # scanned_media_presenter
  it { is_expected.to delegate_method(:text_direction).to(:solr_document) }
  it { is_expected.to delegate_method(:page_number).to(:solr_document) }
  it { is_expected.to delegate_method(:section).to(:solr_document) }
end
