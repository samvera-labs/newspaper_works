require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkFile do
  include_context "shared setup"

  let(:work) { sample_work }
  let(:tiff_path) { File.join(fixture_path, ocr_gray.tiff) }
  let(:tiff_uri) { 'file://' + File.expand_path(tiff_path) }

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
end
