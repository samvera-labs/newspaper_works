require "active_record/railtie"
require 'rspec/rails'
require 'spec_helper'
require 'misc_shared'
require 'newspaper_works/data/work_derivative_loader'

RSpec.describe NewspaperWorks::WorkHelper, type: :helper do
  include_context "shared setup"

  describe "derivative enumeration" do
    it "gets list of derivative names" do
      work = sample_work
      mk_txt_derivative(work)
      work.save!(validate: false)
      result = helper.derivative_names(work)
      expect(result).to include 'txt'
    end
  end
end
