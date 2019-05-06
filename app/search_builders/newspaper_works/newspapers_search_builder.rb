# based heavily on BlacklightAdvancedSearch::AdvancedSearchBuilder
module NewspaperWorks
  class NewspapersSearchBuilder < Hyrax::SearchBuilder
    def facets_for_newspapers_search_form(solr_p)
      # ensure empty query is all records, to fetch available facets on entire corpus
      # solr_p["q"]            = '{!lucene}*:*'
      # explicitly use lucene defType since we are passing a lucene query above (and appears to be required for solr 7)
      # solr_p["defType"]      = 'lucene'
      # TODO: limit results to NewspaperPage and NewspaperArticle only
      # We only care about facets, we don't need any rows.
      solr_p["rows"] = "0"

      # Anything set in config as a literal
      newspaper_facet_config = blacklight_config.advanced_search[:newspapers_search]
      return if newspaper_facet_config.blank?
      solr_p.merge!(newspaper_facet_config[:form_solr_parameters])
    end
  end
end