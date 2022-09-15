require 'nokogiri'
require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::TextFormatsFromALTOService do
  include_context "shared setup"

  let(:valid_file_set) do
    file_set = FileSet.new
    file_set.save!(validate: false)
    file_set
  end

  let(:work) do
    work = NewspaperPage.create(title: ["Hello"])
    work.members << valid_file_set
    work.save!
    work
  end

  let(:minimal_alto) do
    File.join(fixture_path, 'minimal-alto.xml')
  end

  def log_incoming_attachment(fsid)
    NewspaperWorks::DerivativeAttachment.create!(
      fileset_id: fsid,
      path: minimal_alto,
      destination_name: 'xml'
    )
  end

  def derivatives_of(work, fileset)
    NewspaperWorks::Data::WorkDerivatives.of(work, fileset)
  end

  describe "Saves other formats from ALTO" do
    it "saves JSON, text from existing ALTO derivative" do
      derivatives = derivatives_of(work, valid_file_set)
      expect(derivatives.keys.size).to eq 0
      derivatives.attach(minimal_alto, 'xml')
      expect(derivatives.keys.size).to eq 1
      service = described_class.new(valid_file_set)
      service.create_derivatives('/some/random/primary/path/does_not/matter')
      derivatives.load_paths
      expect(derivatives.keys.size).to eq 3
      expect(derivatives.keys).to include 'json', 'txt'
    end

    it "saves JSON, text from incoming ALTO derivative" do
      derivatives = derivatives_of(work, valid_file_set)
      expect(derivatives.keys.size).to eq 0
      log_incoming_attachment(valid_file_set.id)
      service = described_class.new(valid_file_set)
      service.create_derivatives('/some/random/primary/path/does_not/matter')
      # reload keys to check derivatives:
      derivatives.load_paths
      expect(derivatives.keys).to include 'json', 'txt'
    end
  end

  describe "scaling matters" do
    # we need an ingested, characterized file:
    do_now_jobs = [
      IngestLocalFileJob,
      IngestJob,
      InheritPermissionsJob,
      CharacterizeJob
    ]
    # we omit CreateDerivativesJob from above, as obviously duplicative and
    # therefore potential cause of problems here.

    # remove any previous test run (development) artifacts in file
    #   attachment logging tables
    before(:all) do
      NewspaperWorks::DerivativeAttachment.all.delete_all
      NewspaperWorks::IngestFileRelation.all.delete_all
    end

    let(:work) do
      work = NewspaperPage.create(title: ["Hello"])
      work
    end

    let(:tiff_path) { File.join(fixture_path, 'ocr_gray.tiff') }
    let(:ocr_alto_path) do
      File.join(fixture_path, 'ocr_alto_scaled_4pts_per_px.xml')
    end

    def attach_primary_file(work)
      NewspaperWorks::Data::WorkFiles.assign!(to: work, path: tiff_path)
      work.reload
      pcdm_file = NewspaperWorks::Data::WorkFiles.of(work).values[0].unwrapped
      expect(pcdm_file).not_to be_nil
      # we have image dimensions (px) to work with:
      expect(pcdm_file.width[0].to_i).to be_an Integer
      expect(pcdm_file.height[0].to_i).to be_an Integer
    end

    def derivatives_of(work)
      NewspaperWorks::Data::WorkFiles.of(work).derivatives
    end

    def attach_alto(work)
      derivatives = derivatives_of(work)
      derivatives.attach(ocr_alto_path, 'xml')
      # has a path to now-stored derivative:
      expect(derivatives.path('xml')).not_to be_nil
    end

    it "scales ALTO points to original image", perform_enqueued: do_now_jobs do
      attach_primary_file(work)
      attach_alto(work)
      work.reload
      file_set = work.ordered_members.to_a.select { |m| m.class == FileSet }[0]
      service = described_class.new(file_set)
      service.create_derivatives('/a/path/here/needed/but/will/not/matter')
      coords = JSON.parse(derivatives_of(work).data('json'))
      word = coords['coords'].select { |k, _v| k == 'Bethesda' }
      # test against known scaled coordinate of OCR data:
      #   This roughly matches unscaled ALTO data for token 'Bethesda'
      #   in spec/fixtures/files/ocr_alto.xml, with the disclaimer that
      #   round-trip rounding error of 1px is noted for VPOS.
      expect(word['Bethesda']).to eq [[16, 665, 78, 16]]
    end
  end
end
