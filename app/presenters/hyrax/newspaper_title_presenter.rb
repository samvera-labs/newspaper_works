# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitlePresenter < Hyrax::WorkShowPresenter
    delegate :edition, :frequency, :preceded_by, :succeeded_by,
             :publication_date_start, :publication_date_end,
             to: :solr_document
  end
end
