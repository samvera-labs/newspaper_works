require 'json'
require 'spec_helper'

RSpec.describe NewspaperWorks::TextExtraction::ALTOToIIIF do
  let(:fixture_path) do
    File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  let(:sample_alto) { File.join(fixture_path, 'sample-alto.xml') }

  describe "transformation" do
    it "trasnforms ALTO to IIIF annotation list" do
      # Adapter does not take filename, but ALTO as string, so we must read
      alto = File.read(sample_alto)
      adapter = described_class.new(alto)
      # JSON text:
      result = adapter.transform
      # parse to hash:
      loaded_result = JSON.parse(result)
      # mutliple resources == multiple words
      expect(loaded_result['resources'].length).to be > 1
    end
  end
end
