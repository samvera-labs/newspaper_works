# Generated via
#  `rails generate hyrax:work NewspaperIssue`
module Hyrax
  # Newspaper Issue Form Class
  class NewspaperIssueForm < ::NewspaperWorks::NewspaperCoreFormData
    self.model_class = ::NewspaperIssue
    self.terms += [:alternative_title, :volume, :edition, :issue, :extent]
    self.terms -= [:based_near, :creator, :contributor, :date_created,
                   :description, :related_url, :source, :subject]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end
