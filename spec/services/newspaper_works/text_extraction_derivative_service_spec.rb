require 'json'
require 'nokogiri'
require 'spec_helper'

RSpec.describe NewspaperWorks::TextExtractionDerivativeService do
  let(:valid_file_set) do
    file_set = FileSet.new
    file_set.save!(validate: false)
    file_set
  end

  let(:altoxsd) do
    xsdpath = File.join(fixture_path, 'alto-2-0.xsd')
    Nokogiri::XML::Schema(File.read(xsdpath))
  end

  let(:fixture_path) do
    File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  describe "Creates OCR derivatives" do
    def source_image(name)
      File.join(fixture_path, name)
    end

    def expected_path(file_set, ext)
      Hyrax::DerivativePath.derivative_path_for_reference(file_set, ext)
    end

    def validate_alto(filename)
      altoxsd.validate(filename)
    end

    def derivative_exists(ext)
      path = expected_path(valid_file_set, ext)
      expect(File.exist?(path)).to be true
      expect(File.size(path)).to be > 0
    end

    it "creates, stores valid ALTO, plain, IIIF derivatives" do
      # these are in same test to avoid duplicate OCR operation
      service = described_class.new(valid_file_set)
      service.create_derivatives(source_image('ocr_mono.tiff'))
      # ALTO derivative file exists at expected path and validates:
      altoxsd.validate(expected_path(valid_file_set, 'xml'))
      # Plain text exists as non-empty file:
      derivative_exists('txt')
      # IIIF annotation list:
      derivative_exists('json')
      iiif_path = expected_path(valid_file_set, 'json')
      result = File.read(iiif_path)
      loaded_result = JSON.parse(result)
      expect(loaded_result['resources'].length).to be > 0
    end
  end
end
