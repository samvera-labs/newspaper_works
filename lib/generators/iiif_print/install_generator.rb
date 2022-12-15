require 'rails/generators'

module IiifPrint
  # Install Generator Class
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_migrations
      rake "iiif_print:install:migrations"
    end

    def register_worktypes
      inject_into_file 'config/initializers/hyrax.rb',
                       after: "Hyrax.config do |config|\n" do
        "  # Configuration generated by `rails g iiif_print:install`\n" \
          "  config.callback.set(:after_create_fileset) do |file_set, user|\n" \
          "    require 'iiif_print'\n" \
          "    IiifPrint::Data.handle_after_create_fileset(file_set, user)\n" \
          "  end\n" \
          "  #== END GENERATED iiif_print CONFIG ==\n\n"
      end
    end

    def inject_routes
      inject_into_file 'config/routes.rb',
                       after: "Rails.application.routes.draw do\n" do
        "\n  mount IiifPrint::Engine => '/'\n"
      end
    end

    def add_solr_doc
      inject_into_file 'app/models/solr_document.rb',
                       after: "include Hyrax::SolrDocumentBehavior" do
        "\n  include IiifPrint::Solr::Document\n"
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
      generate 'iiif_print:blacklight_iiif_search'
    end

    # NOTE: BlacklightAdvancedSearch generator installs a view partial by default,
    # remove it after install, unless app has already customized that view partial
    def verify_blacklight_adv_search_installed
      return if IO.read('app/controllers/catalog_controller.rb').include?('include BlacklightAdvancedSearch::Controller')
      say_status('info', 'INSTALLING BLACKLIGHT ADVANCED SEARCH', :blue)
      search_form_path = 'app/views/catalog/_search_form.html.erb'
      existing_search_form = File.exist?(search_form_path) ? true : false
      generate 'blacklight_advanced_search:install', '--force'
      remove_file search_form_path unless existing_search_form
    end

    def advanced_search_configuration
      generate 'iiif_print:blacklight_advanced_search'
    end

    def catalog_controller_configuration
      generate 'iiif_print:catalog_controller'
    end

    def inject_configuration
      copy_file 'config/initializers/iiif_print.rb'
    end

    def add_helper
      copy_file "iiif_print_helper.rb", "app/helpers/iiif_print_helper.rb"
    end

    def inject_assets
      generate 'iiif_print:assets'
    end
  end
end
