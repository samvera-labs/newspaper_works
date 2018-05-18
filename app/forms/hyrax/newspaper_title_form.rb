# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  # Newspaper Title Form Class
  class NewspaperTitleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperTitle
    self.terms += [:alternative_title, :resource_type, :genre, :held_by, :issued,
                   :place_of_publication, :edition, :frequency, :issn, :lccn,
                   :oclcnum, :preceded_by, :succeeded_by]
    self.terms -= [:contributor, :creator, :keyword, :related_url, :description,
                   :date_created, :subject, :based_near, :source]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:rights_statement, :creator, :keyword]
  end
end
