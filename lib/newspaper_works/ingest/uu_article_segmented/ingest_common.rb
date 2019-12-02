require 'nokogiri'

module NewspaperWorks
  module Ingest
    module UUArticleSegmented
      # Mixin for common XML functionality for Issue/Page/Article ingest classes
      module IngestCommon
        # @return [Nokogiri::XML::Document] XML document, namespaces removed.
        def doc
          return @doc unless @doc.nil?
          @doc = Nokogiri::XML(File.read(@path))
          @doc.remove_namespaces!
          @doc
        end

        # @param expr [String] XPath expression for query
        # @return [Nokogiri::XML::NodeSet] NodeSet of matching
        #   attribute or element nodes
        def xpath(expr)
          doc.xpath(expr)
        end

        # @return [String] ISO 8601 date stamp
        def publication_date
          Date.parse(date_stamp).to_s  # e.g. from "18-JUN-1860" to ISO8601
        end

        def date_stamp
          xpath('//header-item[@name="date"]').first.text
        end
      end
    end
  end
end
