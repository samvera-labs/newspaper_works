# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  # Newspaper Page Form Class
  class NewspaperPageForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperPage
    self.terms += [:label, :height, :width, :resource_type, :text_direction,
                   :page_number, :section]
    self.terms -= [:title, :creator, :keyword, :rights_statement, :contributor,
                   :description, :license, :subject, :date_created, :subject,
                   :language, :based_near, :related_url, :source,
                   :resource_type, :publisher]
    self.required_fields += [:label, :height, :width]
    self.required_fields -= [:title, :creator, :keyword, :rights_statement]
  end
end
