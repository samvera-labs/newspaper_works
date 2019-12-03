require 'nokogiri'

module NewspaperWorks
  module Ingest
    module UUArticleSegmented
      # Mixin for common XML functionality for Issue/Page/Article ingest classes
      module IngestCommon
        # xpath returns NodeSet for query of @doc:
        delegate :xpath, to: :doc

        # @return [Nokogiri::XML::Document] XML document, namespaces removed.
        def doc
          return @doc unless @doc.nil?
          @doc = Nokogiri::XML(File.read(@path))
          @doc.remove_namespaces!
          @doc
        end

        # @return [String] ISO 8601 date stamp
        def publication_date
          Date.parse(date_stamp).to_s # e.g. from "18-JUN-1860" to ISO8601
        end

        def date_stamp
          xpath('//header-item[@name="date"]').first.text
        end
      end
    end
  end
end
