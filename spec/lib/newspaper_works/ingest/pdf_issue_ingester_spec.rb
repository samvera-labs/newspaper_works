require 'spec_helper'
require 'newspaper_works_fixtures'

RSpec.describe NewspaperWorks::Ingest::PDFIssueIngester do
  include_context "ingest test fixtures"

  describe "ingester construction and composition" do
    it "constructs ingester with expected metadata" do
      # given path to 'pdf_batch/sn93059126' directory containing PDFs:
      ingester = described_class.new(pdf_fixtures)
      # correctly parses LCCN from path:
      expect(ingester.lccn).to eq 'sn93059126'
      expect(ingester.path).to eq pdf_fixtures
    end

    it "constructs ingester with publication metadata" do
      ingester = described_class.new(pdf_fixtures)
      expect(ingester.publication).to be_a NewspaperWorks::Ingest::PublicationInfo
      expect(ingester.publication.lccn).to eq ingester.lccn
      expect(ingester.publication.title).to eq 'The weekly journal.'
    end

    it "constructs ingester with explicit LCCN" do
      # path is for The weekly journal (Chicopee Mass), pass LCCN for other pub
      sltrib = 'sn83045396'
      ingester = described_class.new(pdf_fixtures, sltrib)
      expect(ingester.lccn).to eq sltrib
      expect(ingester.publication.lccn).to eq ingester.lccn
      expect(ingester.publication.title).to eq 'Salt Lake tribune'
    end

    it "constructs ingester enumerating PDF files" do
      ingester = described_class.new(pdf_fixtures)
      pdfs = Dir.entries(pdf_fixtures).select { |name| name.end_with?('.pdf') }
      paths = pdfs.map { |name| File.join(pdf_fixtures, name) }
      issues = ingester.issues
      expect(issues).to be_a NewspaperWorks::Ingest::PDFIssues
      expect(issues.size).to eq pdfs.size
      expect(issues.keys).to match_array paths
    end
  end

  describe "ingester behavior" do
    it "ingests PDFs" do
      # TODO: implement
    end
  end
end
