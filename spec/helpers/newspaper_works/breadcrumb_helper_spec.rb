require 'spec_helper'
RSpec.describe NewspaperWorks::BreadcrumbHelper do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      'publication_id_ssi' => 'foo',
      'publication_title_ssi' => 'bar',
      'issue_id_ssi' => 'baz',
      'issue_title_ssi' => 'quux'
    }
  end
  let(:presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }
  let(:object_type) { :issue }

  describe '#newspaper_breadcrumbs' do
    it 'returns an array of links' do
      beadcrumbs = helper.newspaper_breadcrumbs(presenter)
      expect(beadcrumbs.length).to eq 2
      expect(beadcrumbs[0]).to include('href="/concern/newspaper_titles/foo"')
      expect(beadcrumbs[1]).to include('href="/concern/newspaper_issues/baz"')
    end
  end

  describe '#create_breadcrumb_link' do
    it 'returns an array of links' do
      array_for_spec = helper.create_breadcrumb_link(object_type, presenter)
      expect(array_for_spec.class).to eq Array
      expect(array_for_spec.first).to include('href="/concern/newspaper_issues/baz"')
    end
  end

  describe '#breadcrumb_object_link' do
    it 'returns a link a newspaper object' do
      link_for_spec = helper.breadcrumb_object_link(object_type, 'foo', 'bar')
      expect(link_for_spec).to include('href="/concern/newspaper_issues/foo"')
    end
  end
end
