# custom SearchBuilder generated by IiifPrint; adds behavior to Hyrax::CatalogSearchBuilder:
# - BlacklightAdvancedSearch::AdvancedSearchBuilder, to support /newspapers_search
# - IiifPrint::HighlightSearchParams, to support highlighting and snippets in results
# - IiifPrint::ExcludeModels, to remove NewspaperTitle, NewspaperContainer,
#     and NewspaperIssue objects from keyword searches
class CustomSearchBuilder < Hyrax::CatalogSearchBuilder
  include IiifPrint::HighlightSearchParams
  include IiifPrint::ExcludeModels

  # :exclude_models and :highlight_search_params must be added after advanced_search
  #   so keyword query input can be properly eval'd
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr,
                                   :exclude_models, :highlight_search_params]

  # add logic to BlacklightAdvancedSearch::AdvancedSearchBuilder
  # so that date range params are recognized as advanced search
  # rubocop:disable Naming/PredicateName
  def is_advanced_search?
    blacklight_params[:date_start].present? || blacklight_params[:date_end].present? || super
  end
  # rubocop:enable Naming/PredicateName
end