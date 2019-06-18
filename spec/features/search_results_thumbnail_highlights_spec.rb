require 'spec_helper'

RSpec.describe 'newspapers_search' do
  fixture_path = File.join(NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files')
  let(:query_term) { 'rotunda' }

  # use before(:all) so we only create fixtures once
  # we use instance var for @work so we can access its id in specs
  # rubocop:disable RSpec/InstanceVariable
  before(:all) do
    whitelist = Hyrax.config.whitelisted_ingest_dirs
    whitelist.push(fixture_path) unless whitelist.include?(fixture_path)

    @work = NewspaperPage.create!(title: ['Test Page for Thumbnail Highlights'])
    attachment = NewspaperWorks::Data::WorkFiles.of(@work)
    attachment.assign(File.join(fixture_path, 'page1.tiff'))
    attachment.derivatives.assign(File.join(fixture_path, 'ndnp-sample1-txt.txt'))
    attachment.derivatives.assign(File.join(fixture_path, 'ndnp-sample1-json.json'))
    attachment.commit!
    @work.save!
  end

  before do
    visit search_catalog_path(q: query_term)
  end

  describe 'thumbnail highlighting' do
    it 'adds a highlight div to thumbnail' do
      within "#document_#{@work.id}" do
        expect(page).to have_selector '.thumbail_highlight'
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
