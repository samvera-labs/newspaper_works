# require 'model_shared'
RSpec.describe 'hyrax/newspaper_titles/show.html.erb', type: :view do
  let!(:publication) do
    publication = NewspaperTitle.new
    publication.title = ["Wall Street Journal"]
    publication.save
    publication
  end

  let!(:issues) do
    issue1 = NewspaperIssue.new
    issue1.title = ['February 13, 2019']
    issue1.resource_type = ["newspaper"]
    issue1.genre = ["text"]
    issue1.language = ["eng"]
    issue1.held_by = "Marriott Library"
    issue1.publication_date = '2019-02-13'
    publication.members.push << issue1
    issue2 = NewspaperIssue.new
    issue2.title = ['March 5, 2019']
    issue2.resource_type = ["newspaper"]
    issue2.genre = ["text"]
    issue2.language = ["eng"]
    issue2.held_by = "Marriott Library"
    issue2.publication_date = '2019-03-05'
    publication.members.push << issue2
    [issue1, issue2]
  end

  let(:title_solr_document) { SolrDocument.find(publication.id) }

  let(:file_set_solr_document) do
    SolrDocument.new(id: '888',
                     title_tesim: ['Title Fileset'],
                     depositor_tesim: depositor.user_key)
  end

  let(:ability) { double }
  let(:page) { Capybara::Node::Simple.new(rendered) }
  let(:current_request) { double('current_request', host: 'test.host', params: {}) }

  let(:presenter) do
    Hyrax::NewspaperTitlePresenter.new(title_solr_document, ability, current_request)
  end

  let(:workflow_presenter) do
    double('workflow_presenter', badge: 'Foobar')
  end

  let(:work_type) do
    double
  end

  let(:representative_presenter) do
    Hyrax::FileSetPresenter.new(file_set_solr_document, ability)
  end

  let(:depositor) do
    stub_model(User,
               user_key: 'bob',
               twitter_handle: 'bot4lib')
  end

  before do
    allow(presenter).to receive(:issues).and_return(issues)
    allow(presenter).to receive(:workflow).and_return(workflow_presenter)
    allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
    allow(presenter).to receive(:representative_id).and_return(publication.id)
    allow(presenter).to receive(:tweeter).and_return("@#{depositor.twitter_handle}")
    allow(presenter).to receive(:human_readable_type).and_return("Newspaper Title")
    allow(controller).to receive(:current_user).and_return(depositor)
    allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
    # allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:signed_in?)
    allow(view).to receive(:on_the_dashboard?).and_return(false)
    stub_template 'catalog/_search_form.html.erb' => ''
    stub_template 'hyrax/base/_metadata.html.erb' => ''
    stub_template 'hyrax/base/_relationships.html.erb' => ''
    stub_template 'hyrax/base/_show_actions.html.erb' => ''
    stub_template 'hyrax/base/_social_media.html.erb' => ''
    stub_template 'hyrax/base/_citations.html.erb' => ''
    stub_template 'shared/_citations.html.erb' => ''
    stub_template 'hyrax/base/_items.html.erb' => ''
    stub_template 'hyrax/base/_workflow_actions_widget.html.erb' => ''
    stub_template '_items' => ''
    stub_template '_relationships' => ''
    stub_template '_work_title' => ''
    stub_template '_work_type' => ''
    stub_template '_masthead.html.erb' => ''
    stub_template '_issues_calendar.html.erb' => ''
    assign(:presenter, presenter)
    render template: 'hyrax/newspaper_titles/show.html.erb', layout: 'layouts/hyrax/1_column'
  end

end
