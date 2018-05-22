module NewspaperWorks
  class NewspaperCoreFormData < Hyrax::Forms::WorkForm
    self.terms += [:resource_type, :genre, :issued, :place_of_publication,
                   :issn, :lccn, :oclcnum, :held_by]
    self.terms -= [:keyword]
  end
end
