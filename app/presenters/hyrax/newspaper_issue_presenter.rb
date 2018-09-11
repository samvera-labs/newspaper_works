# Generated via
#  `rails generate hyrax:work NewspaperIssue`
module Hyrax
  class NewspaperIssuePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    delegate :volume, :edition, :issue_number, :extent, :publication_date,
             to: :solr_document
  end
end
