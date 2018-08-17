# Core indexer for newspaper work types
module NewspaperWorks
  class NewspaperCoreIndexer < Hyrax::WorkIndexer
    # This indexes the default metadata. You can remove it if you want to
    # provide your own metadata and indexing.
    include Hyrax::IndexesBasicMetadata
    include NewspaperWorks::IndexesPlaceOfPublication
    include NewspaperWorks::IndexesPublicationDate

    # Fetch remote labels for based_near. You can remove this if you don't want
    # this behavior
    # include Hyrax::IndexesLinkedMetadata

    def generate_solr_document
      super.tap do |solr_doc|
        index_pup(object.place_of_publication, solr_doc) if object.place_of_publication.present?
        index_pubdate_start(object.publication_date_start, solr_doc) if object.publication_date_start.present?
        index_pubdate_end(object.publication_date_end, solr_doc) if object.publication_date_end.present?
      end
    end
  end
end
