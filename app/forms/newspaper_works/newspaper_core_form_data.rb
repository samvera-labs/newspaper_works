module NewspaperWorks
  class NewspaperCoreFormData < Hyrax::Forms::WorkForm
    self.terms += [:resource_type, :genre, :issued, :place_of_publication,
                   :issn, :lccn, :oclcnum, :held_by]
    self.terms -= [:keyword]
    self.required_fields += [:resource_type, :genre, :language, :held_by]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end
