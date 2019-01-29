# based on Hyrax::Renderers::RightsStatementAttributeRenderer
module Hyrax
  module Renderers
    # This is used by PresentsAttributes to show genres for NewspaperArticle
    #   e.g.: presenter.attribute_to_html(:genre, render_as: :genre)
    class GenreAttributeRenderer < FacetedAttributeRenderer
      private

      ##
      # Special treatment for genre, so we can store term URI in Fedora, but use label
      def attribute_value_to_html(value)
        label = Hyrax::ArticleGenreService.new.label(value) { value }
        li_value(label)
      end
    end
  end
end