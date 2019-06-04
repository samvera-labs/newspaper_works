require 'spec_helper'

describe NewspaperWorks::Ingest do
  describe "Ingest module methods" do
    it "gets default admin set" do
      admin_set = described_class.find_admin_set
      expect(admin_set).to be_an AdminSet
      expect(admin_set.id).to eq AdminSet::DEFAULT_ID
    end

    it "sets default assigned metadata for a work" do
      work = NewspaperTitle.create!(title: ["hello"])
      expect(work.admin_set).to be_nil
      expect(work.depositor).to be_nil
      expect(work.visibility).to eq 'restricted'
      described_class.assign_administrative_metadata(work)
      expect(work.admin_set).not_to be_nil
      expect(work.admin_set).to eq AdminSet.find(AdminSet::DEFAULT_ID)
      expect(work.depositor).to eq User.batch_user.user_key
      expect(work.visibility).to eq 'open'
    end
  end
end
