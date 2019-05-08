require 'rails/generators'

module NewspaperWorks
  # Install Generator Class
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_migrations
      rake "newspaper_works:install:migrations"
    end

    def register_worktypes
      inject_into_file 'config/initializers/hyrax.rb',
                       after: "Hyrax.config do |config|\n" do
        "  # Configuration generated by `rails g newspaper_works:install`\n" \
          "  config.register_curation_concern :newspaper_article\n" \
          "  config.register_curation_concern :newspaper_container\n" \
          "  config.register_curation_concern :newspaper_issue\n" \
          "  config.register_curation_concern :newspaper_page\n" \
          "  config.register_curation_concern :newspaper_title\n" \
          "  config.callback.set(:after_create_fileset) do |file_set, user|\n" \
          "    require 'newspaper_works'\n" \
          "    NewspaperWorks::Data.handle_after_create_fileset(file_set, user)\n" \
          "  end\n" \
          "  #== END GENERATED newspaper_works CONFIG ==\n\n"
      end
    end

    def inject_routes
      inject_into_file 'config/routes.rb',
                       after: "Rails.application.routes.draw do\n" do
        "\n  mount NewspaperWorks::Engine => '/'\n"
      end
    end

    def add_solr_doc
      inject_into_file 'app/models/solr_document.rb',
                       after: "include Hyrax::SolrDocumentBehavior" do
        "\n  include NewspaperWorks::Solr::Document\n"
      end
    end

    def verify_biiif_installed
      return if IO.read('app/controllers/catalog_controller.rb').include?('include BlacklightIiifSearch::Controller')
      say_status('info',
                 'BLACKLIGHT IIIF SEARCH NOT INSTALLED; INSTALLING BLACKLIGHT IIIF SEARCH',
                 :blue)
      generate 'blacklight_iiif_search:install'
    end

    def iiif_configuration
      generate 'newspaper_works:blacklight_iiif_search'
    end

    def verify_blacklight_adv_search_installed
      return if IO.read('app/controllers/catalog_controller.rb').include?('include BlacklightAdvancedSearch::Controller')
      say_status('info',
                 'INSTALLING BLACKLIGHT ADVANCED SEARCH',
                 :blue)
      generate 'blacklight_advanced_search:install', '--force'
    end

    def advanced_search_configuration
      generate 'newspaper_works:blacklight_advanced_search'
    end

    def inject_authorities
      inject_into_file 'config/authorities/resource_types.yml',
                       after: "term: Masters Thesis\n" do
        "  - id: Microfilm\n" \
        "    term: Microfilm\n" \
        "  - id: Newspaper\n" \
        "    term: Newspaper\n"
      end
      copy_file "config/authorities/newspaper_article_genres.yml"
    end

    # rubocop:disable Metrics/MethodLength
    def add_facets_to_catalog_controller
      marker = 'configure_blacklight do |config|'
      inject_into_file 'app/controllers/catalog_controller.rb', after: marker do
        "\n\n    # NewspaperWorks facet fields\n"\
        "    config.add_facet_field solr_name('place_of_publication_city', :facetable), label: 'Place of publication', limit: 5\n"\
        "    config.add_facet_field 'publication_title_ssi', label: 'Publication title', limit: 5\n"\
        "    config.add_facet_field solr_name('genre', :facetable), label: 'Article type', limit: 5\n\n"\
        "    # additional NewspaperWorks fields not displayed in the facet list,\n"\
        "    # but below definitions give labels to filters for linked metadata\n"\
        "    config.add_facet_field solr_name('place_of_publication_label', :facetable), label: 'Place of publication', if: false\n"\
        "    config.add_facet_field solr_name('issn', :facetable), label: 'ISSN', if: false\n"\
        "    config.add_facet_field solr_name('lccn', :facetable), label: 'LCCN', if: false\n"\
        "    config.add_facet_field solr_name('oclcnum', :facetable), label: 'OCLC #', if: false\n"\
        "    config.add_facet_field solr_name('held_by', :facetable), label: 'Held by', if: false\n"\
        "    config.add_facet_field solr_name('author', :facetable), label: 'Author', if: false\n"\
        "    config.add_facet_field solr_name('photographer', :facetable), label: 'Photographer', if: false\n"\
        "    config.add_facet_field solr_name('geographic_coverage', :facetable), label: 'Geographic coverage', if: false\n"\
        "    config.add_facet_field solr_name('preceded_by', :facetable), label: 'Preceded by', if: false\n"\
        "    config.add_facet_field solr_name('succeeded_by', :facetable), label: 'Succeeded by', if: false\n"\
        "    config.add_facet_field 'first_page_bsi', label: 'First page', if: false\n"
      end
    end
    # rubocop:enable Metrics/MethodLength

    def inject_configuration
      copy_file 'config/initializers/newspaper_works.rb'
    end

    def add_helper
      copy_file "newspaper_works_helper.rb", "app/helpers/newspaper_works_helper.rb"
    end

    def inject_assets
      generate 'newspaper_works:assets'
    end
  end
end
