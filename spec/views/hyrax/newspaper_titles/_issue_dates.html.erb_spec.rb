require 'spec_helper'
RSpec.describe 'hyrax/newspaper_titles/_issue_dates.html.erb', type: :view do
  let(:years_count) do
    { 1939 => 10, 1940 => 20, 1941 => 30, 1942 => 40, 1943 => 50, 1944 => 60, 1945 => 70  }
  end

  it 'shows graph' do
    render partial: "issue_dates.html.erb", locals: { params: {id: 12345}, years: years_count }
    expect(rendered).to have_content('1939', '1940', '1941', '1942', '1943', '1944', '1945')
  end
end
