require 'spec_helper'
RSpec.describe Hyrax::NewspaperTitlePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }

  subject { described_class.new(double, double) }

  # def publication_date_start
  #   solr_document["publication_date_start_dtsim"][0]
  # end
  #
  # def publication_date_end
  #   solr_document["publication_date_end_dtsim"][0]
  # end

  it { is_expected.to delegate_method(:edition).to(:solr_document) }
  it { is_expected.to delegate_method(:frequency).to(:solr_document) }
  it { is_expected.to delegate_method(:preceded_by).to(:solr_document) }
  it { is_expected.to delegate_method(:succeeded_by).to(:solr_document) }

  # newspaper_core_presenter
  it { is_expected.to delegate_method(:alternative_title).to(:solr_document) }
  it { is_expected.to delegate_method(:genre).to(:solr_document) }
  it { is_expected.to delegate_method(:place_of_publication).to(:solr_document) }
  it { is_expected.to delegate_method(:issn).to(:solr_document) }
  it { is_expected.to delegate_method(:lccn).to(:solr_document) }
  it { is_expected.to delegate_method(:oclcnum).to(:solr_document) }
  it { is_expected.to delegate_method(:held_by).to(:solr_document) }
end
