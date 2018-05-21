# Generated via
#  `rails generate hyrax:work NewspaperArticle`
module Hyrax
  class NewspaperArticleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperArticle
    self.terms += [:resource_type, :genre, :issued, :place_of_publication,
                   :issn, :lccn, :oclcnum, :held_by]
    self.terms += [:subtitle, :author, :photographer, :volume, :edition, :issue,
                   :section, :subject, :geographic_coverage, :extent,
                   :pagination, :section]
    self.terms -= [:keyword]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end
