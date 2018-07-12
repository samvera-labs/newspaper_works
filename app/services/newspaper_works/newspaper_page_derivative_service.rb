module NewspaperWorks
  # Base type for derivative services specific to NewspaperPage only
  class NewspaperPageDerivativeService
    attr_reader :file_set, :master_format
    delegate :uri, :mime_type, to: :file_set

    def initialize(file_set)
      @file_set = file_set
    end

    def valid?
      # plugins of this base type only valid for NewspaperPage
      file_set.in_works[0].class == NewspaperPage
    end

    def create_derivatives(filename); end

    def cleanup_derivatives; end
  end
end
