# require 'model_shared'
RSpec.describe 'hyrax/newspaper_titles/show.html.erb', type: :view do
  let(:title_solr_document) do
    SolrDocument.new(id: '999',
                     title_tesim: ['Wall Street Journal'],
                     genre_tesim: ['Newspaper'],
                     language_tesim: ['English'],
                     language_sim: ['English'],
                     held_by: ['Library'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     has_model_ssim: ['NewspaperTitle'],
                     depositor_tesim: depositor.user_key,
                     resource_type_tesim: ['Other'],
                     member_ids_ssim: ['888', '123'])
  end

  let(:issue1_solr_document) do
    SolrDocument.new(id: '123',
                     title_tesim: ['Tyson Made Its Fortune Packing Meat. Now It Wants to Sell You Frittatas.'],
                     genre_tesim: ['Newspaper'],
                     language_tesim: ['English'],
                     language_sim: ['English'],
                     held_by: ['Library'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     publication_date_dtsi: ['2019-02-13T00:00:00Z'],
                     has_model_ssim: ['NewspaperIssue'],
                     depositor_tesim: depositor.user_key,
                     resource_type_tesim: ['Other'],
                     member_ids_ssim: ['111'])
  end

  let(:issue1_file_set_solr_document) do
    SolrDocument.new(id: '111',
                     title_tesim: ['Issue1 Fileset'],
                     depositor_tesim: depositor.user_key)
  end

  let(:title_file_set_solr_document) do
    SolrDocument.new(id: '888',
                     title_tesim: ['Title Fileset'],
                     depositor_tesim: depositor.user_key)
  end

  let(:ability) { double }
  let(:page) { Capybara::Node::Simple.new(rendered) }
  let(:request) { double('request', host: 'test.host') }

  let(:issue1_presenter) do
    Hyrax::NewspaperIssuePresenter.new(issue1_solr_document, ability, request)
  end

  let(:title_presenter) do
    Hyrax::NewspaperTitlePresenter.new(title_solr_document, ability, request)
  end

  let(:workflow_presenter) do
    double('workflow_presenter', badge: 'Foobar')
  end

  let(:representative_presenter) do
    Hyrax::FileSetPresenter.new(title_file_set_solr_document, ability)
  end

  let(:depositor) do
    stub_model(User,
               user_key: 'bob',
               twitter_handle: 'bot4lib')
  end

  before do
    allow(title_presenter).to receive(:workflow).and_return(workflow_presenter)
    allow(title_presenter).to receive(:representative_presenter).and_return(representative_presenter)
    allow(title_presenter).to receive(:representative_id).and_return('999')
    allow(title_presenter).to receive(:tweeter).and_return("@#{depositor.twitter_handle}")
    allow(title_presenter).to receive(:human_readable_type).and_return("Newspaper Title")
    allow(controller).to receive(:current_user).and_return(depositor)
    allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:signed_in?)
    allow(view).to receive(:on_the_dashboard?).and_return(false)
    stub_template 'hyrax/base/_metadata.html.erb' => ''
    stub_template 'hyrax/base/_relationships.html.erb' => ''
    stub_template 'hyrax/base/_show_actions.html.erb' => ''
    stub_template 'hyrax/base/_social_media.html.erb' => ''
    stub_template 'hyrax/base/_citations.html.erb' => ''
    stub_template 'hyrax/base/_items.html.erb' => ''
    stub_template 'hyrax/base/_workflow_actions_widget.html.erb' => ''
    stub_template '_masthead.html.erb' => ''
    assign(:presenter, presenter)
    render template: 'hyrax/newspaper_titles/show.html.erb', layout: 'layouts/hyrax/1_column'
  end

  it 'shows workflow badge' do
    expect(page).to have_content 'Foobar'
  end
end
