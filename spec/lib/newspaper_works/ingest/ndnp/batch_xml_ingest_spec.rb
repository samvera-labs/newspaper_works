require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::BatchXMLIngest do
  include_context "ndnp fixture setup"

  describe "sample batch" do
    let(:batch) { described_class.new(batch1) }

    it "gets batch name" do
      expect(batch.name).to eq 'batch_test'
    end

    it "gets issue by path" do
      path = batch.issue_paths[0]
      issue = batch.get(path)
      expect(issue).to be_a NewspaperWorks::Ingest::NDNP::IssueIngest
      expect(issue.path).to eq path
    end

    it "gets reel/container by path" do
      path = batch.container_paths[0]
      container = batch.get(path)
      expect(container).to be_a NewspaperWorks::Ingest::NDNP::ContainerIngest
      expect(container.path).to eq path
    end

    it "enumerates container paths" do
      reel_ids = batch.container_paths
      expect(reel_ids).to be_an Array
      expect(reel_ids.size).to eq 3
    end

    it "enumerates issue paths" do
      issue_ids = batch.issue_paths
      expect(issue_ids).to be_an Array
      expect(issue_ids.size).to eq 4
    end

    it "enumerates issues" do
      issues = batch.issues
      expect(issues).to be_an Array
      expect(issues.size).to eq 4
      expect(issues[0]).to be_a NewspaperWorks::Ingest::NDNP::IssueIngest
    end

    it "enumerates containers" do
      reels = batch.containers
      expect(reels).to be_an Array
      expect(reels.size).to eq 3
      expect(reels[0]).to be_a NewspaperWorks::Ingest::NDNP::ContainerIngest
    end
  end
end
