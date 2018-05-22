# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  # Newspaper Title Form Class
  class NewspaperTitleForm < ::NewspaperWorks::NewspaperCoreFormData
    self.model_class = ::NewspaperTitle
    self.terms += [:alternative_title, :edition, :frequency, :preceded_by,
                   :succeeded_by]
    self.terms -= [:based_near, :creator, :contributor, :date_created,
                   :description, :related_url, :source, :subject]
  end
end
