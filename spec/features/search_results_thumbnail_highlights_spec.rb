require 'spec_helper'

RSpec.describe 'thumbnail_highlights', js: true do
  fixture_path = File.join(NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files')
  let(:query_term) { 'rotunda' }

  # use before(:all) so we only create fixtures once
  # we use instance var for @work so we can access its id in specs
  before(:all) do
    whitelist = Hyrax.config.whitelisted_ingest_dirs
    whitelist.push(fixture_path) unless whitelist.include?(fixture_path)

    @work = NewspaperPage.create!(
      title: ['Test Page for Thumbnail Highlights'],
      visibility: "open"
    )
    attachment = NewspaperWorks::Data::WorkFiles.of(@work)
    attachment.assign(File.join(fixture_path, 'page1.tiff'))
    attachment.derivatives.assign(File.join(fixture_path, 'ndnp-sample1-txt.txt'))
    attachment.derivatives.assign(File.join(fixture_path, 'ndnp-sample1-json.json'))
    attachment.commit!
    @work.save!
  end

  describe 'thumbnail highlighting' do
    it 'adds highlight divs to thumbnail' do
      visit search_catalog_path(q: 'rotunda scarcely')
      within "#document_#{@work.id}" do
        expect(page).to have_selector('.thumbnail_highlight', count: 2)
      end
    end
  end
end
