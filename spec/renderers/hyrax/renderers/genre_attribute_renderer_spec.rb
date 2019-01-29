require 'spec_helper'

RSpec.describe Hyrax::Renderers::GenreAttributeRenderer do
  let(:field) { :genre }
  let(:term) { 'http://id.loc.gov/vocabulary/graphicMaterials/tgm000098' }
  let(:renderer) { described_class.new(field, [term]) }

  describe "#attribute_to_html" do
    subject { renderer.render }

    it 'has the correct label for the term' do
      expect(subject).to include('Advertisement')
    end

    it 'renders as a facet link' do
      expect(subject).to include("<a href=\"/catalog?")
    end
  end
end
