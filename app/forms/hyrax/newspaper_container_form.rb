# Generated via
#  `rails generate hyrax:work NewspaperContainer`
module Hyrax
  # Newspaper Container Form Class
  class NewspaperContainerForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperContainer
    self.terms += [:resource_type, :held_by, :place_of_publication,
                   :alternative_title, :issued, :issn, :lccn, :oclcnum, :extent]
    self.terms -= [:creator, :keyword, :contributor, :description, :location,
                   :related_url, :date_created, :subject, :based_near, :source]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end
