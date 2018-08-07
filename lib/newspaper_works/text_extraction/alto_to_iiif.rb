require 'nokogiri'

module NewspaperWorks
  # Module for text extraction (OCR or otherwise)
  module TextExtraction
    class ALTOToIIIF
      # Construct with ALTO XML as string
      def initialize(alto)
        @xml = alto
      end

      def template
        xsl_dir = File.join(NewspaperWorks::GEM_PATH, 'vendor', 'xslt')
        xsl_path = File.join(xsl_dir, 'annotationListNoArt.xsl')
        Nokogiri::XSLT(File.read(xsl_path))
      end

      def transform
        document = Nokogiri::XML(@xml)
        # transform, return JSON string
        template.transform(document).text
      end
    end
  end
end
