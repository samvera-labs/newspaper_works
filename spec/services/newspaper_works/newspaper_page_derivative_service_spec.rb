require 'spec_helper'

RSpec.describe NewspaperWorks::NewspaperPageDerivativeService do
  let(:valid_file_set) do
    fs = FileSet.new
    work = NewspaperPage.new
    work.title = ['This is a page!']
    work.members.push(fs)
    fs.save!(validate: false)
    work.save!(validate: false)
    fs
  end

  let(:unconsidered_file_set) do
    fs = FileSet.new
    work = NewspaperIssue.new
    work.title = ['Hello Hello']
    work.members.push(fs)
    work.save!(validate: false)
    fs.save!(validate: false)
    fs
  end

  describe "abstract functionality" do
    class MyDerivativeService < described_class
      TARGET_EXT = 'jpg'.freeze
    end

    it "allows derivative service subclass to define file extension" do
      svc = MyDerivativeService.new(valid_file_set)
      expect(svc.class.target_ext).to eq 'jpg'
    end

    it "considers file_sets belonging to page work type" do
      svc = MyDerivativeService.new(valid_file_set)
      expect(svc.valid?).to eq true
    end

    it "ignores file_sets belonging to non-page work type" do
      svc = MyDerivativeService.new(unconsidered_file_set)
      expect(svc.valid?).to eq false
    end

    it "gets derivative path factory for file extension" do
      svc = MyDerivativeService.new(valid_file_set)
      svc.load_destpath
      expected = Hyrax::DerivativePath.derivative_path_for_reference(
        valid_file_set,
        'jpg'
      )
      expected_pairtree = File.join(expected.split('/')[0..-2])
      expect(Pathname.new(expected_pairtree)).to be_directory
      # cleanup:
      FileUtils.rm_rf(expected_pairtree)
    end
  end
end
