require 'spec_helper'
RSpec.describe Hyrax::NewspaperPagePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      'is_following_page_of_ssi' => 'foo',
      'is_preceding_page_of_ssi' => 'bar',
      'container_id_ssi' => 'baz',
      'container_title_ssi' => 'quux',
      'article_ids_ssim' => ['123456'],
      'article_titles_ssim' => ['Test Title']
    }
  end
  subject { described_class.new(solr_document, double) }

  describe 'object relationship methods' do
    describe '#previous_page_id' do
      it 'returns the correct value' do
        expect(subject.previous_page_id).to eq 'foo'
      end
    end

    describe '#next_page_id' do
      it 'returns the correct value' do
        expect(subject.next_page_id).to eq 'bar'
      end
    end

    describe '#container_id' do
      it 'returns the correct value' do
        expect(subject.container_id).to eq 'baz'
      end
    end

    describe '#container_title' do
      it 'returns the correct value' do
        expect(subject.container_title).to eq 'quux'
      end
    end

    describe '#article_ids' do
      it 'returns the correct value' do
        expect(subject.article_ids).to eq ['123456']
      end
    end

    describe '#article_titles' do
      it 'returns the correct value' do
        expect(subject.article_titles).to eq ['Test Title']
      end
    end
  end
end
