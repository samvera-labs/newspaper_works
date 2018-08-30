# Generated via
#  `rails generate hyrax:work NewspaperPage`
class NewspaperPageIndexer < NewspaperWorks::NewspaperCoreIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  # include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  # include Hyrax::IndexesLinkedMetadata

  def index_full_text(solr_doc, work)
    # Get text from plain text derivative
    text = NewspaperWorks::Data::WorkDerivativeLoader.new(work).data('txt')
    # index as single-value text in solr:
    solr_doc['full_text_tesi'] = text
  end

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      index_full_text(solr_doc, object)
    end
  end
end
