require 'spec_helper'

describe NewspaperWorks::Ingest::PubFinder do
  describe "mixin publication find-or-create module" do
    let(:klass) do
      Class.new do
        include NewspaperWorks::Ingest::PubFinder
      end
    end

    before do
      ['sn2036999999', 'sn2036999999'].each do |lccn|
        NewspaperTitle.where(lccn: lccn).delete_all
      end
    end

    # use factory for saved NewspaperIssue:
    let(:issue) { create(:newspaper_issue) }

    let(:ingester) { klass.new }

    let(:publication) { create(:newspaper_title) }

    it "finds existing publication, if it exists" do
      lccn = publication.lccn
      expect(ingester.find_publication(lccn)).to be_a NewspaperTitle
    end

    it "links existing publication on find-or-create" do
      lccn = publication.lccn
      ingester.find_or_create_publication_for_issue(issue, lccn, nil, {})
      publication.reload
      expect(publication.ordered_members.to_a).to include issue
    end

    it "links issue to new publication" do
      lccn = 'sn2099999999'
      expect(ingester.find_publication(lccn)).to be_nil
      ingester.find_or_create_publication_for_issue(issue, lccn, nil, {})
      publication = ingester.find_publication(lccn)
      expect(publication).to be_a NewspaperTitle
      expect(publication.ordered_members.to_a).to include issue
    end
  end
end
