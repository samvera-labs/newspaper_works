# Generated via
#  `rails generate hyrax:work NewspaperArticle`
module Hyrax
  class NewspaperArticlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    include NewspaperWorks::ScannedMediaPresenter
    delegate :author, :photographer, :volume, :edition, :issue_number,
             :geographic_coverage, :extent, :publication_date,
             to: :solr_document
  end
end
