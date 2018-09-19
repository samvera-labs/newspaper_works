require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkDerivativeLoader do
  include_context "shared setup"

  describe "enumerates available derivatives" do
    it "includes expected derivative path for work" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      loader = described_class.new(work)
      ext_found = loader.paths.map { |v| v.split('.')[-1] }
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for work" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      loader = described_class.new(work)
      ext_found = loader.to_a
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      file_set = work.members.select { |m| m.class == FileSet }[0]
      loader = described_class.new(file_set)
      ext_found = loader.to_a
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set id" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      file_set = work.members.select { |m| m.class == FileSet }[0]
      loader = described_class.new(file_set.id)
      ext_found = loader.to_a
      expect(ext_found).to include 'txt'
    end
  end

  describe "loads derivatives for a work" do
    it "Loads text derivative path" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      loader = described_class.new(work)
      expect(File.exist?(loader.path('txt'))).to be true
    end

    it "Loads text derivative data" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      loader = described_class.new(work)
      expect(loader.data('txt')).to include 'mythical'
    end

    it "Can access jp2 derivative" do
      work = sample_work
      mk_jp2_derivative(work)
      work.save!(validate: false)
      loader = described_class.new(work)
      expect(File.exist?(loader.path('jp2'))).to be true
    end
  end
end
