# Generated via
#  `rails generate hyrax:work NewspaperIssue`
module Hyrax
  # Newspaper Issue Form Class
  class NewspaperIssueForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperIssue
    self.terms += [:alternative_title, :resource_type, :genre,
                   :place_of_publication, :volume, :edition, :issue, :language,
                   :issn, :lccn, :oclcnum, :extent, :held_by, :issued]
    self.terms -= [:creator, :keyword, :related_url, :source, :description,
                   :contributor, :date_created, :subject, :based_near]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:creator, :rights_statement, :keyword]
  end
end
