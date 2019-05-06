# adds controller-scope behavior to the implementing application
require 'rails/generators'

module NewspaperWorks
  class BlacklightAdvancedSearchGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "
  This generator makes the following changes to your app:
   1. Creates a new SearchBuilder class that inherits from Hyrax::CatalogSearchBuilder
   2. Adjusts config.search_builder_class settings in CatalogController
   3. Adds configuration to config.advanced_search settings in CatalogController
   4. Adds an initializer to patch some BlacklightAdvancedSearch classes to allow for date range searches
         "

    # add the new SearchBuilder
    def inject_search_builder
      copy_file 'custom_search_builder.rb',
                'app/models/custom_search_builder.rb'
    end

    # Update the default SearchBuilder class
    def update_search_builder
      gsub_file('app/controllers/catalog_controller.rb',
                "config.search_builder_class = Hyrax::CatalogSearchBuilder",
                "config.search_builder_class = CustomSearchBuilder")
    end

    # add newspapers field info to advanced_search config
    def add_newspapers_advanced_config
      marker = 'config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new'
      inject_into_file 'app/controllers/catalog_controller.rb', after: marker do
        "\n    config.advanced_search[:newspapers_search] = {\n"\
        "      form_solr_parameters: {\n"\
        "        \"facet.field\" => [\"publication_title_ssi\", \"place_of_publication_label_sim\", \"language_sim\", \"genre_sim\"],\n"\
        "        \"facet.limit\" => -1,\n"\
        "        \"facet.sort\" => \"index\"\n"\
        "      }\n"\
        "    }\n"
      end
    end
  end
end
