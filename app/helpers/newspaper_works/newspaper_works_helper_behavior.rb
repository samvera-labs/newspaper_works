module NewspaperWorks
  module NewspaperWorksHelperBehavior
    ##
    # create link anchor to be read by UniversalViewer
    # in order to show keyword search
    # @param query [String]
    # @return [String] or [nil] anchor
    def iiif_search_anchor(query)
      return nil if query.blank?
      "?h=#{query}"
    end

    ##
    # based on Blacklight::CatalogHelperBehavior#render_thumbnail_tag
    # Render the thumbnail, if available, for a NewspaperPage or Article
    # link it to the document record, with anchor for UV IIIF search
    #
    # @param document [SolrDocument]
    # @param query [String]
    # @return [String]
    def render_newspaper_thumbnail_tag(document, query)
      value = if blacklight_config.view_config(document_index_view_type).thumbnail_method
                send(blacklight_config.view_config(document_index_view_type).thumbnail_method,
                     document,
                     image_options)
              elsif blacklight_config.view_config(document_index_view_type).thumbnail_field
                image_tag blacklight_config.view_config(document_index_view_type).thumbnail_field
              end
      if value
        case document[blacklight_config.index.display_type_field.to_sym].first
        when 'NewspaperPage'
          link_to(value, hyrax_newspaper_page_path(document.id,
                                                   anchor: iiif_search_anchor(query)))
        when 'NewspaperArticle'
          link_to(value, hyrax_newspaper_article_path(document.id,
                                                      anchor: iiif_search_anchor(query)))
        else
          link_to_document document, value
        end
      end
    end
  end
end