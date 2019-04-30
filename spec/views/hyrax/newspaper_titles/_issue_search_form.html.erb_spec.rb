require 'spec_helper'
RSpec.describe 'hyrax/newspaper_titles/_issue_search_form.html.erb', type: :view do
  let(:presenter) { double }

  before do
    allow(view).to receive(:search_form_action).and_return("/catalog")
    allow(view).to receive(:search_state).and_return(search_state)
    allow(view).to receive(:current_search_parameters).and_return(nil)
    allow(view).to receive(:current_user).and_return(nil)

    allow(presenter).to receive(:title_search_params).and_return(f: { "human_readable_type_sim" => ["Newspaper Page"], "publication_id_ssi" => ["9p2909328"] })
    assign(:presenter, presenter)
    render
  end
  let(:search_state) { double('SearchState', params_for_search: {}) }
  let(:page) { Capybara::Node::Simple.new(rendered) }

  it "has a hidden f[human_readable_type_sim][] input" do
    expect(page).to have_selector("[name='f\[human_readable_type_sim\]\[\]'][value='Newspaper Page']", visible: false)
  end

  it "has a hidden f[publication_id_ssi][] input" do
    expect(page).to have_selector("[name='f\[publication_id_ssi\]\[\]'][value='9p2909328']", visible: false)
  end

  it "has a q field for query" do
    expect(page).to have_field("q")
  end
end
