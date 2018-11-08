module Hyrax
  module NewspaperPagesHelper
    include NewspaperWorks::BreadcrumbHelper

    def previous_page_link(presenter)
      link_to t('hyrax.newspaper_page.previous_page'),
              main_app.hyrax_newspaper_page_path(presenter.previous_page_id)

    end

    def next_page_link(presenter)
      link_to t('hyrax.newspaper_page.next_page'),
              main_app.hyrax_newspaper_page_path(presenter.next_page_id)

    end
  end
end