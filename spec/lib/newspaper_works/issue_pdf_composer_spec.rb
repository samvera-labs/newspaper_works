require 'spec_helper'

RSpec.describe NewspaperWorks::IssuePDFComposer do
  let(:bare_issue) do
    build(:newspaper_issue)
  end

  let(:fixtures_path) do
    fixtures = File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files')
    Hyrax.config.whitelisted_ingest_dirs.push(fixtures)
    fixtures
  end

  let(:pdf_path) do
    File.join(fixtures_path, 'minimal-1-page.pdf')
  end

  let(:broken_pdf) do
    File.join(fixtures_path, 'broken-truncated.pdf')
  end

  def page_with_pdf(name, path)
    # empty+saved fileset: only need id, no primary file, to attach derivatives
    fs = FileSet.create!
    page = NewspaperPage.create!(title: [name])
    page.members << fs
    page.save!
    derivatives = NewspaperWorks::Data::WorkDerivatives.of(page)
    derivatives.assign(path)
    derivatives.commit!
    page
  end

  let(:page1_with_pdf) { page_with_pdf('Page 1', pdf_path) }
  let(:page2_with_pdf) { page_with_pdf('Page 2', pdf_path) }

  let(:broken_page) { page_with_pdf('Broken Page', broken_pdf) }

  let(:two_page_issue) do
    issue = NewspaperIssue.create(title: ['Issue Test'])
    issue.ordered_members << page1_with_pdf
    issue.ordered_members << page2_with_pdf
    issue.save!
    issue
  end

  let(:unfinished_issue) do
    issue = NewspaperIssue.create(title: ['Unfinished issue'])
    issue.members << FileSet.create!
    issue.save!
    issue.ordered_members << broken_page
    issue.save!
    issue
  end

  describe "adapter construction" do
    it "constructs adapter" do
      composer = described_class.new(bare_issue)
      expect(composer.issue).to be bare_issue
      expect(composer.page_pdfs).to match_array []
    end
  end

  describe "Validation and handling of not-yet-ready pages" do
    it "validates PDFs" do
      # we can fake issue context with nil on construction to call validate_pdf
      composer = described_class.new(nil)
      expect(composer.validate_pdf(broken_pdf)).to be false
      expect(composer.validate_pdf(pdf_path)).to be true
    end

    it "raises NewspaperWorks::PagesNotReady on incomplete PDF" do
      composer = described_class.new(unfinished_issue)
      expect { composer.compose }.to raise_error(NewspaperWorks::PagesNotReady)
    end
  end

  describe "Construction, attachment of combined PDF" do
    it "creates issue PDF from sources" do
      composer = described_class.new(two_page_issue)
      derivatives = NewspaperWorks::Data::WorkDerivatives.of(two_page_issue)
      expect(derivatives.exist?('pdf')).to be false
      # Make the mulit-page-pdf with IssuePDFComposer#compose:
      composer.compose
      # reload issue derivatives, as they have been updated:
      derivatives = NewspaperWorks::Data::WorkDerivatives.of(two_page_issue)
      # upon reload of cached derivative paths, we see a PDF:
      expect(derivatives.exist?('pdf')).to be true
    end
  end
end
