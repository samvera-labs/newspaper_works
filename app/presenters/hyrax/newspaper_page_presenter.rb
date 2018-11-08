# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  class NewspaperPagePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::ScannedMediaPresenter
    include NewspaperWorks::TitleInfoPresenter
    include NewspaperWorks::IssueInfoPresenter
    delegate :height, :width, to: :solr_document

    def previous_page_id
      solr_document['is_following_page_of_ssi']
    end

    def next_page_id
      solr_document['is_preceding_page_of_ssi']
    end

    def container_id
      solr_document['container_id_ssi']
    end

    def container_title
      solr_document['container_title_ssi']
    end

    def article_ids
      solr_document['article_ids_ssim']
    end

    def article_titles
      solr_document['article_titles_ssim']
    end
  end
end
