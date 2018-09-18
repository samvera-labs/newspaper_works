require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkDerivativeLoader do
  include_context "shared setup"

  describe "enumerates available derivatives for work" do
    it "includes expected derivative path" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      loader = described_class.new(work)
      ext_found = loader.paths.map { |v| v.split('.')[-1] }
      expect(ext_found).to include 'txt'
    end

    it "includes expected derivative extensions" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      loader = described_class.new(work)
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
