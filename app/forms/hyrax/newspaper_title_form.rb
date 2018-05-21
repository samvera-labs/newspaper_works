# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  # Newspaper Title Form Class
  class NewspaperTitleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperTitle
    self.terms += [:resource_type, :genre, :issued, :place_of_publication,
                   :issn, :lccn, :oclcnum, :held_by]
    self.terms += [:alternative_title, :edition, :frequency, :preceded_by,
                   :succeeded_by]
    self.terms -= [:based_near, :creator, :contributor, :date_created,
                   :description, :keyword, :related_url, :source, :subject]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end
