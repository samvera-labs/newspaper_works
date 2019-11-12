require 'spec_helper'

RSpec.describe NewspaperWorks::IndexesPlaceOfPublication do
  let(:ntitle) { NewspaperTitle.new }
  let(:test_indexer) { NewspaperTitleIndexer.new(ntitle) }
  let(:geonames_id) { '4950065' }
  let(:geonames_uri) { "http://sws.geonames.org/#{geonames_id}/" }
  let(:pop) { Hyrax::ControlledVocabularies::Location.new(geonames_uri) }
  # stub this, so we don't make repeated calls to GeoNames API
  let(:geodata) { test_indexer.get_geodata(geonames_id) }

  describe '#index_pop' do
    let(:solr_doc) { {} }
    before do
      allow(test_indexer).to receive(:get_geodata).and_return(geodata)
      ntitle.place_of_publication = [pop]
      test_indexer.index_pop(ntitle, solr_doc)
    end
    it 'sets the geodata fields correctly' do
      expect(solr_doc['place_of_publication_state_sim'].first).not_to be_falsey
      expect(solr_doc['place_of_publication_geojson_ssim'].first).not_to be_falsey
    end
  end

  describe '#add_geodata_fields' do
    let(:solr_doc) { {} }
    before { test_indexer.add_geodata_fields(solr_doc) }
    it 'adds the geodata fields' do
      expect(solr_doc['place_of_publication_county_sim'].class).to eq(Array)
      expect(solr_doc['place_of_publication_label_tesim'].class).to eq(Array)
    end
  end

  describe '#index_pop_geodata' do
    let(:solr_doc) { {} }
    before do
      test_indexer.add_geodata_fields(solr_doc)
      test_indexer.index_pop_geodata(geodata, solr_doc)
    end
    it 'parses the geodata correctly' do
      expect(solr_doc['place_of_publication_city_sim']).to include('Salem')
      expect(solr_doc['place_of_publication_geojson_ssim']).to include('-70.89672,42.51954')
    end
  end

  describe '#get_geodata' do
    it 'returns a hash of structured geodata' do
      expect(geodata.class).to eq(Hash)
      expect(geodata['name']).not_to be_falsey
      expect(geodata['lat']).not_to be_falsey
    end
  end

  describe '#geojson_for_coords' do
    let(:geojson) { test_indexer.geojson_for_coords(geodata['lat'], geodata['lng']) }
    it 'returns a GeoJSON hash' do
      expect(geojson.class).to eq(Hash)
      expect(geojson['type']).to eq 'Feature'
      expect(geojson['geometry']['coordinates']).to eq [-70.89672, 42.51954]
    end
  end
end
