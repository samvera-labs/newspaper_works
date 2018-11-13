require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkFiles do
  include_context "shared setup"

  let(:work) { sample_work }
  let(:tiff_path) { File.join(fixture_path, 'ocr_gray.tiff') }
  let(:tiff_uri) { 'file://' + File.expand_path(tiff_path) }

  describe "adapter composition" do
    it "adapts work" do
      adapter = described_class.new(work)
      expect(adapter.work).to be work
    end

    it "adapts work with 'of' alt constructor" do
      adapter = described_class.of(work)
      expect(adapter.work).to be work
    end
  end

  describe "path assignment queueing" do
    it "queues assigned file path" do
      adapter = described_class.of(work)
      expect(adapter.assigned).to be_empty
      # assign a valid source path
      adapter.assign(tiff_path)
      expect(adapter.assigned).to include tiff_path
    end

    it "queues a file:/// URI" do
      adapter = described_class.of(work)
      expect(adapter.assigned).to be_empty
      adapter.assign(tiff_uri)
      expect(adapter.assigned).to include tiff_uri
    end

    it "queues a Pathname, normalized to string" do
      adapter = described_class.of(work)
      expect(adapter.assigned).to be_empty
      adapter.assign(Pathname.new(tiff_path))
      expect(adapter.assigned).to include tiff_path
    end

    it "unqueues a queued path" do
      adapter = described_class.of(work)
      adapter.assign(tiff_path)
      expect(adapter.assigned).to include tiff_path
      adapter.unassign(tiff_path)
      expect(adapter.assigned).to be_empty
    end
  end
end
