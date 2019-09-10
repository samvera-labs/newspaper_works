# based heavily on BlacklightAdvancedSearch::AdvancedSearchBuilder
# this class is used to set params on the search that is performed to
# display facet values on the Newspapers Search form,
# NOT the search results when a user submits the form
module NewspaperWorks
  class NewspapersSearchBuilder < Hyrax::SearchBuilder
    self.default_processor_chain += [:facets_for_newspapers_search_form,
                                     :newspaper_pages_only,
                                     :ocr_search_params]

    def facets_for_newspapers_search_form(solr_params)
      # we only care about facets, we don't need any rows.
      solr_params["rows"] = "0"

      # add anything set in config as a literal
      newspaper_facet_config = blacklight_config.advanced_search[:newspapers_search]
      return if newspaper_facet_config.blank?
      solr_params.merge!(newspaper_facet_config[:form_solr_parameters])
    end

    def newspaper_pages_only(solr_params)
      type_field = Solrizer.solr_name('human_readable_type', :facetable)
      type_value = NewspaperPage.human_readable_type
      solr_params[:fq] ||= []
      solr_params[:fq] << "#{type_field}:\"#{type_value}\""
    end

    # set params for ocr field searching
    def ocr_search_params(solr_parameters = {})
      config_ocr_search_field = 'all_text_tsimv'
      solr_parameters[:facet] = false
      solr_parameters[:hl] = true
      solr_parameters[:'hl.fl'] = config_ocr_search_field
      solr_parameters[:'hl.fragsize'] = 135
      solr_parameters[:'hl.snippets'] = 10
    end
  end
end
