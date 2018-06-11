# Generated via
#  `rails generate hyrax:work NewspaperTitle`
class NewspaperTitleIndexer < NewspaperWorks::NewspaperCoreIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  # include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  # include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  # def generate_solr_document
  #  super.tap do |solr_doc|
  #    solr_doc['my_custom_field_ssim'] = object.my_custom_property
  #  end
  # end

  def generate_solr_document
    super.tap do |solr_doc|
      if object.publication_date_start =~ /\A\d{4}\z/
        index_date = "#{object.publication_date_start}-01-01T00:00:00Z"
        solr_doc['publication_date_start_dtsim'] = index_date
      elsif object.publication_date_start =~ /\A\d{4}-\d{2}\z/
        index_date = "#{object.publication_date_start}-01T00:00:00Z"
        solr_doc['publication_date_start_dtsim'] = index_date
      end

      if object.publication_date_end =~ /\A\d{4}\z/
        index_date = "#{object.publication_date_end}-12-31T23:59:59Z"
        solr_doc['publication_date_end_dtsim'] = index_date
      elsif object.publication_date_end =~ /\A\d{4}-\d{2}\z/
        date_split = object.publication_date_end.split('-')
        end_day = Date.new(date_split[0].to_i, date_split[1].to_i, -1).strftime("%d")
        index_date = "#{object.publication_date_end}-#{end_day}T23:59:59Z"
        solr_doc['publication_date_end_dtsim'] = index_date
      end

    end
  end

end
