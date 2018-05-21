# Generated via
#  `rails generate hyrax:work NewspaperArticle`
module Hyrax
  class NewspaperArticleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperArticle
    self.terms += [:subtitle, :author, :photographer, :resource_type, :genre,
                   :place_of_publication, :volume, :edition, :issue, :section,
                   :subject, :geographic_coverage, :issn, :lccn, :oclcnum,
                   :extent, :pagination, :held_by, :section]
    self.terms -= [:keyword]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end
