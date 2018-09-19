# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    delegate :edition, :frequency, :preceded_by, :succeeded_by,
             to: :solr_document

    def publication_date_start
      solr_document["publication_date_start_dtsim"][0]
    end

    def publication_date_end
      solr_document["publication_date_end_dtsim"][0]
    end
  end
end
