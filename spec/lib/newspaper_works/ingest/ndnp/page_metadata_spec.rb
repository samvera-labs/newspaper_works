require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::PageMetadata do
  include_context "ndnp fixture setup"

  def construct(path, dmdid)
    described_class.new(path, nil, dmdid)
  end

  describe "sample fixture 'batch_local'" do
    it "gets expected page number as String" do
      page = construct(issue1, 'pageModsBib8')
      expect(page.page_number).to eq "1"
      page = construct(issue1, 'pageModsBib6')
      expect(page.page_number).to eq "2"
    end

    it "gets expected sequence number as Integer" do
      page = construct(issue1, 'pageModsBib8')
      expect(page.page_sequence_number).to eq 1
      page = construct(issue1, 'pageModsBib6')
      expect(page.page_sequence_number).to eq 2
    end

    it "gets expected width from ALTO as Integer " do
      page = construct(issue1, 'pageModsBib8')
      expect(page.width).to eq 18_352
      page = construct(issue1, 'pageModsBib6')
      expect(page.width).to eq 18_200
    end

    it "gets expected height from ALTO as Integer " do
      page = construct(issue1, 'pageModsBib8')
      expect(page.height).to eq 28_632
      page = construct(issue1, 'pageModsBib6')
      expect(page.height).to eq 28_872
    end

    it "gets identifier from ALTO as primary file name" do
      page = construct(issue1, 'pageModsBib8')
      expect(page.identifier).to eq "/mnt/nash.iarchives.com/data01/jobq/root/projects/production/LeanProcessing/UofU/Park_Record/Park_Record_Set01/tpr_19350705-19380630/ocr/0657b.tif"
      page = construct(issue1, 'pageModsBib6')
      expect(page.identifier).to eq "/mnt/nash.iarchives.com/data01/jobq/root/projects/production/LeanProcessing/UofU/Park_Record/Park_Record_Set01/tpr_19350705-19380630/ocr/0656a.tif"
    end
  end

  describe "sample fixture 'batch_test_ver01" do
    it "returns nil page number for page without one" do
      page = construct(issue2, 'pageModsBib1')
      expect(page.page_number).to eq nil
    end

    it "gets expected sequence number as Integer" do
      page = construct(issue2, 'pageModsBib1')
      expect(page.page_sequence_number).to eq 1
    end

    it "gets expected width from ALTO as Integer " do
      page = construct(issue2, 'pageModsBib1')
      expect(page.width).to eq 21_464
    end

    it "gets expected height from ALTO as Integer " do
      page = construct(issue2, 'pageModsBib1')
      expect(page.height).to eq 30_268
    end

    it "gets identifier from ALTO as primary file name" do
      page = construct(issue2, 'pageModsBib1')
      expect(page.identifier).to eq "././0225.tif"
    end
  end
end
