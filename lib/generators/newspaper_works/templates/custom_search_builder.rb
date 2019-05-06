# custom SearchBuilder that adds BlacklightAdvancedSearch to Hyrax::CatalogSearchBuilder
class CustomSearchBuilder < Hyrax::CatalogSearchBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
end
