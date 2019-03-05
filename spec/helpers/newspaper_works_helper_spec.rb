require 'spec_helper'

RSpec.describe NewspaperWorksHelper do
  let(:query) { 'suffrage' }

  describe '#iiif_search_anchor' do
    it 'returns the correct string' do
      expect(helper.iiif_search_anchor(nil)).to eq nil
      expect(helper.iiif_search_anchor(query)).to eq("?h=#{query}")
    end
  end
end