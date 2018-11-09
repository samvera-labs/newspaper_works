require 'spec_helper'
RSpec.describe Hyrax::NewspaperArticlePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org') }
  let(:attributes) { { 'page_ids_ssim' => ['foo'], 'page_titles_ssim' => ['bar'] } }
  let(:ability) { nil }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  describe 'object relationship methods' do
    describe '#page_ids' do
      it 'returns the correct value' do
        expect(presenter.page_ids).to eq ['foo']
      end
    end

    describe '#page_title' do
      it 'returns the correct value' do
        expect(presenter.page_titles).to eq ['bar']
      end
    end
  end
end
