require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::IssueMetadata do
  include_context "ndnp fixture setup"

  def construct(path)
    described_class.new(path)
  end

  describe "sample fixture 'batch_local'" do
    it "gets lccn" do
      issue = construct(issue1)
      expect(issue.lccn).to eq "sn85058233"
    end

    it "gets volume" do
      issue = construct(issue1)
      expect(issue.volume).to eq "56"
    end

    it "gets issue" do
      issue = construct(issue1)
      expect(issue.issue).to eq "27"
    end

    it "gets edition" do
      issue = construct(issue1)
      expect(issue.edition).to eq "Main Edition"
    end

    it "gets publication date" do
      issue = construct(issue1)
      expect(issue.publication_date).to eq "1935-08-02"
    end

    it "gets held_by" do
      issue = construct(issue1)
      expect(issue.held_by).to eq "University of Utah; Salt Lake City, UT"
    end
  end

  describe "sample fixture 'batch_test_ver01" do
    it "gets lccn" do
      issue = construct(issue2)
      expect(issue.lccn).to eq "sn85025202"
    end

    it "gets volume" do
      issue = construct(issue2)
      expect(issue.volume).to eq "2"
    end

    it "gets issue" do
      issue = construct(issue2)
      expect(issue.issue).to eq "4"
    end

    it "gets edition" do
      issue = construct(issue2)
      expect(issue.edition).to eq "1"
    end

    it "gets publication date" do
      issue = construct(issue2)
      expect(issue.publication_date).to eq "1857-02-14"
    end

    it "gets held_by" do
      issue = construct(issue2)
      expect(issue.held_by).to eq "University of Utah, Salt Lake City, UT"
    end
  end
end
