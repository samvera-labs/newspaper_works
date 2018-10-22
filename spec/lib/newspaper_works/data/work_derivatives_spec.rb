require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkDerivatives do
  include_context "shared setup"

  let(:work) do
    # sample work comes from shared setup, but we need derivative, save...
    mk_txt_derivative(sample_work)
    sample_work.save!(validate: false)
    sample_work
  end

  let(:txt1) do
    file = Tempfile.new('txt1.txt')
    file.write('hello')
    file.close
    file.path
  end

  let(:txt2) do
    file = Tempfile.new('txt2.txt')
    file.write('bye')
    file.close
    file.path
  end

  describe "enumerates available derivatives like hash" do
    it "includes expected derivative path for work" do
      adapter = described_class.new(work)
      expect(adapter.keys).to include 'txt'
    end

    it "can be introspected for quantity of derivatives" do
      # `size` method without argument is count of derivatives,
      #   functions equivalently to adapter.keys.size
      adapter = described_class.new(work)
      expect(adapter.size).to eq adapter.keys.size
    end

    it "enumerates expected derivative extension for work" do
      adapter = described_class.new(work)
      ext_found = adapter.keys
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set" do
      file_set = work.members.select { |m| m.class == FileSet }[0]
      adapter = described_class.new(file_set)
      ext_found = adapter.keys
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set id" do
      file_set = work.members.select { |m| m.class == FileSet }[0]
      adapter = described_class.new(file_set.id)
      ext_found = adapter.keys
      expect(ext_found).to include 'txt'
    end
  end

  describe "loads derivatives for a work" do
    it "Loads text derivative path" do
      adapter = described_class.new(work)
      expect(File.exist?(adapter.path('txt'))).to be true
      expect(adapter.exist?('txt')).to be true
    end

    it "Loads text derivative data" do
      adapter = described_class.new(work)
      expect(adapter.data('txt')).to include 'mythical'
    end

    it "Loads thumbnail derivative data" do
      mk_thumbnail_derivative(work)
      adapter = described_class.new(work)
      # get size by loading data
      expect(adapter.data('thumbnail').size).to eq 16_743
      # get size by File.size via .size method
      expect(adapter.size('thumbnail')).to eq 16_743
    end

    it "Can access jp2 derivative" do
      mk_jp2_derivative(work)
      adapter = described_class.new(work)
      expect(File.exist?(adapter.path('jp2'))).to be true
      expect(adapter.exist?('jp2')).to be true
    end
  end

  describe "create, update, delete derivatives" do
    it "can attach derivative from file" do
      adapter = described_class.new(work)
      expect(adapter.keys).not_to include 'jp2'
      adapter.attach(example_gray_jp2, 'jp2')
      expect(adapter.exist?('jp2')).to be true
      expect(adapter.path('jp2')).not_to be nil
      expect(File.size(adapter.path('jp2'))).to eq File.size(example_gray_jp2)
      expect(adapter.keys).to include 'jp2'
      d_path = path_factory.derivative_path_for_reference(adapter.fileset_id, 'jp2')
      expect(adapter.values).to include d_path
    end

    it "can replace a derivative with new attachment" do
      adapter = described_class.new(work)
      adapter.attach(txt1, 'txt')
      expect(adapter.data('txt')).to eq 'hello'
      adapter.attach(txt2, 'txt')
      expect(adapter.data('txt')).to eq 'bye'
    end

    it "can delete an attached derivative" do
      adapter = described_class.new(work)
      adapter.attach(txt1, 'txt')
      expect(adapter.keys).to include 'txt'
      expect(adapter.data('txt')).to eq 'hello'
      adapter.delete('txt')
      expect(adapter.path('txt')).to be nil
      expect(adapter.keys).not_to include 'txt'
    end
  end
end
