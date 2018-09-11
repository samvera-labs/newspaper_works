# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  class NewspaperPagePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::ScannedMediaPresenter
    delegate :height, :width, to: :solr_document
  end
end
