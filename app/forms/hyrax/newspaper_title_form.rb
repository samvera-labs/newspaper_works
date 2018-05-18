# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  # Newspaper Title Form Class
  class NewspaperTitleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperTitle
    self.terms += [:alternative_title, :resource_type, :genre, :held_by, :issued,
                   :place_of_publication, :edition, :frequency, :issn, :lccn, :oclcnum]
    self.required_fields += [:title, :resource_type, :genre, :language, :held_by]
    self.required_fields -= [:rights]
  end
end
