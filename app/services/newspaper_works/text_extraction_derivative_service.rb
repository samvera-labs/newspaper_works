module NewspaperWorks
  class TextExtractionDerivativeService < NewspaperPageDerivativeService
    def initialize(file_set)
      super(file_set)
      @alto_path = nil
      @txt_path = nil
    end

    def create_derivatives(filename)
      @source_path = filename
      # prepare destination directory for ALTO (as .xml files):
      @alto_path = prepare_path('xml')
      # prepare destination directory for plain text (as .txt files):
      @txt_path = prepare_path('txt')
      # prepare destination directory for IIIF anno list (as .json files):
      @iiif_path = prepare_path('json')
      ocr = NewspaperWorks::TextExtraction::PageOCR.new(filename)
      # OCR will run once, on first method call to either .alto or .plain:
      write_plain_text(ocr.plain)
      # write ALTO and IIIF (transformed from ALTO):
      write_alto(ocr.alto)
      write_iiif_from_alto(ocr.alto)
    end

    def write_alto(xml)
      File.open(@alto_path, 'w') do |outfile|
        outfile.write(xml)
      end
    end

    def write_iiif_from_alto(xml)
      result = NewspaperWorks::TextExtraction::ALTOToIIIF.new(xml).transform
      File.open(@iiif_path, 'w') do |outfile|
        outfile.write(result)
      end
    end

    def write_plain_text(text)
      File.open(@txt_path, 'w') do |outfile|
        outfile.write(text)
      end
    end

    def cleanup_derivatives
      super('txt')
      super('xml')
    end
  end
end
