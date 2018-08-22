require 'spec_helper'

RSpec.describe NewspaperWorks::NewspaperCoreIndexer do
  let(:geonames_id) { 'http://sws.geonames.org/4950065/' }
  let(:pup) { Hyrax::ControlledVocabularies::Location.new(geonames_id) }
  let(:article) do
    NewspaperArticle.new(
      id: 'foo1234',
      title: ['Whatever'],
      place_of_publication: pup
    )
  end
  let(:indexer) { described_class.new(article) }

  describe '#generate_solr_document' do
    subject { indexer.generate_solr_document }

    # TODO: check for existence of other fields once geonames username added to test suite
    it 'processes place_of_publication field' do
      expect(subject['place_of_publication_tesim']).to include(geonames_id)
    end
  end
end
