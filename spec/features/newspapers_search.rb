require 'spec_helper'

RSpec.describe 'newspapers_search' do
  # use this so titles are different every time spec is run
  # this prevents tests from accidentally failing because view only shows 10 results
  # and our newly created fixtures may not show up on first results page
  title_base = 'Mxyzptlk'.chars.shuffle.join

  # have to create NewspaperIssues because NewspaperPage inherits
  # relevant metadata from parent during indexing
  before(:all) do
    issue1 = NewspaperIssue.new
    issue1.title = ["#{title_base}: July 4, 1965"]
    issue1.resource_type = ["newspaper"]
    issue1.language = ["English"]
    issue1.held_by = "Marriott Library"
    issue1.publication_date = '1965-07-04'
    issue1.visibility = 'open'
    issue1_page1 = NewspaperPage.new
    issue1_page1.title = ["#{title_base}: July 4, 1965: Page 1"]
    issue1_page1.visibility = 'open'
    issue1_page2 = NewspaperPage.new
    issue1_page2.title = ["#{title_base}: July 4, 1965: Page Foo"]
    issue1_page2.visibility = 'open'
    issue1.ordered_members << issue1_page1
    issue1.ordered_members << issue1_page2
    issue1.save!
    issue1_page1.save!
    issue1_page2.save!
    issue2 = NewspaperIssue.new
    issue2.title = ["#{title_base}: July 4, 1969"]
    issue2.resource_type = ["newspaper"]
    issue2.language = ["Spanish"]
    issue2.held_by = "Marriott Library"
    issue2.publication_date = '1969-07-04'
    issue2.visibility = 'open'
    issue2_page1 = NewspaperPage.new
    issue2_page1.title = ["#{title_base}: July 4, 1969: Page Bar"]
    issue2_page1.visibility = 'open'
    issue2.ordered_members << issue2_page1
    issue2.save!
    issue2_page1.save!
  end

  before do
    visit newspaper_works.newspapers_search_path
    fill_in "all_fields", with: title_base
  end

  it 'returns results for keyword search' do
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).to have_content 'Page 1'
      expect(page).to have_content 'Page Foo'
      expect(page).to have_content 'Page Bar'
    end
  end

  it 'returns correct results for keyword search with front page' do
    check 'f_first_page_bsi_'
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).not_to have_content 'Page Foo'
      expect(page).to have_content 'Page Bar'
    end
  end

  it 'returns correct results for keyword search with date' do
    fill_in "date_range_start", with: '1965'
    fill_in "date_range_end", with: '1966'
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).to have_content 'Page 1'
      expect(page).not_to have_content 'Page Bar'
    end
  end

  it 'returns correct results for keyword search with facet' do
    check 'f_inclusive_language_sim_spanish'
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).not_to have_content 'Page 1'
      expect(page).to have_content 'Page Bar'
    end
  end
end
