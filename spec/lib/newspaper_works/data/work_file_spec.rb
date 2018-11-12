require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkFile do
  include_context "shared setup"

  # shared date to be invariant across all tests in a run:
  static_date = Hyrax::TimeService.time_in_utc

  # path fixtures:
  let(:tiff_path) { File.join(fixture_path, ocr_gray.tiff) }
  let(:tiff_uri) { 'file://' + File.expand_path(tiff_path) }
  let(:txt_path) { File.join(fixture_path, 'credits.md') }

  # sample objects:
  let(:work) do
    # we need a work with not just a valid (but empty) fileset, but also
    #   a persisted file, so we use the shared work sample, and expand
    #   on it with actual file data/metadata.
    work = sample_work
    fileset = work.members.select { |m| m.class == FileSet }[0]
    file = Hydra::PCDM::File.create
    fileset.original_file = file
    # Set binary content on file via ActiveFedora content= mutator method
    #   which also makes .size method return valid result for content
    file.content = File.open(txt_path)
    # Set some metdata we would expect to otherwise be set upon an upload
    file.original_name = 'credits.md'
    file.mime_type = 'text/plain'
    file.date_modified = static_date
    file.date_created = static_date
    # saving fileset also saves file content
    fileset.save!
    work
  end

  describe "adapter composition" do
    it "adapts work with implied fileset" do
      adapter = described_class.new(work)
      expect(adapter.work).to be work
      fileset = work.members.select { |m| m.class == FileSet }[0]
      expect(adapter.fileset).to be fileset
    end

    it "adapts work with 'of' alt constructor" do
      adapter = described_class.of(work)
      expect(adapter.work).to be work
    end

    it "adapts work and explicitly provided fileset" do
      fileset = work.members.select { |m| m.class == FileSet }[0]
      adapter = described_class.of(work, fileset)
      expect(adapter.work).to be work
      expect(adapter.fileset).to be fileset
    end

    it "constructs with a parent object, if provided" do
      fileset = work.members.select { |m| m.class == FileSet }[0]
      parent = double('parent')
      adapter = described_class.of(work, fileset, parent)
      expect(adapter.parent).to be parent
    end
  end

  describe "read file metadata" do
    it "gets original filename" do
      fileset = work.members.select { |m| m.class == FileSet }[0]
      adapter = described_class.of(work, fileset)
      expect(adapter.name).to eq fileset.original_file.original_name
      expect(adapter.name).to eq 'credits.md'
    end

    it "gets miscellaneous metadata field values" do
      fileset = work.members.select { |m| m.class == FileSet }[0]
      adapter = described_class.of(work, fileset)
      # expectations for accessors of size, date_*, mime_type
      expect(adapter.size).to eq File.size(txt_path)
      expect(adapter.name).to eq 'credits.md'
      expect(adapter.mime_type).to eq 'text/plain'
      # getting actual value for date fields requires digging through
      #   multiple layers of ActiveTuples indirection...
      expect(adapter.date_created.to_a[0].to_s).to eq static_date.to_s
      expect(adapter.date_modified.to_a[0].to_s).to eq static_date.to_s
    end
  end

  describe "read binary via transparent repository checkout" do
    it "gets path" do
    end

    it "gets data as bytes" do
    end

    it "runs block on data as IO" do
    end
  end
end
