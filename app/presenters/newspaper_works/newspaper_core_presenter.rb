# module comment...
module NewspaperWorks
  # core presenter for newspaper models
  module NewspaperCorePresenter
    delegate :alternative_title, :genre, :issn, :lccn,
             :oclcnum, :held_by, to: :solr_document
  end
end
