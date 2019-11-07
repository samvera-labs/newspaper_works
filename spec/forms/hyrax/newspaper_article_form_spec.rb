require 'spec_helper'
require 'model_shared'

RSpec.describe Hyrax::NewspaperArticleForm do
  let(:work) { NewspaperArticle.new }
  let(:form) { described_class.new(work, nil, nil) }

  let(:hyrax3) { Hyrax::VERSION.start_with?('3') }

  describe "#required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq [:title, :resource_type, :language, :held_by] }
  end

  describe "#primary_terms" do
    subject { form.primary_terms }

    it { is_expected.to eq [:title, :resource_type, :language, :held_by] }
  end

  describe "#secondary_terms" do
    subject { form.secondary_terms }

    it "has expected secondary terms for Hyrax 3" do
      if hyrax3
        is_expected.to eq [
          :alt_title, :creator, :contributor, :description, :abstract,
          :license, :rights_statement, :access_right, :rights_notes,
          :publisher, :subject, :identifier, :place_of_publication, :issn,
          :lccn, :oclcnum, :alt_title, :genre, :author, :photographer,
          :publication_date, :volume, :edition_number, :edition_name,
          :issue_number, :geographic_coverage, :extent, :page_number, :section
        ]
      end
    end

    it "has expected secondary terms for Hyrax 2" do
      unless hyrax3
        is_expected.to eq [
          :alt_title, :creator, :contributor, :description,
          :license, :rights_statement,
          :publisher, :subject, :identifier, :place_of_publication, :issn,
          :lccn, :oclcnum, :alt_title, :genre, :author, :photographer,
          :publication_date, :volume, :edition_number, :edition_name,
          :issue_number, :geographic_coverage, :extent, :page_number, :section
        ]
      end
    end
  end
end
