# based heavily on BlacklightAdvancedSearch::AdvancedController
module NewspaperWorks
  class NewspapersSearchController < CatalogController
    # we need this for proper routing of search forms/links
    def search_action_url(*args)
      main_app.search_catalog_url(*args)
    end

    def search_builder_class
      NewspaperWorks::NewspapersSearchBuilder
    end

    def search
      @response = get_newspaper_search_facets
    end

    protected

      def get_newspaper_search_facets
        response, = search_results(params) do |search_builder|
          search_builder.except(:add_advanced_search_to_solr)
        end
        response
      end
  end
end
