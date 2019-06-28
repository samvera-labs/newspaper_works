require 'faraday'
require 'nokogiri'

module NewspaperWorks
  module Ingest
    # Publication info from ChronAm as remote authority for metadata
    class ChronAmPublicationInfo < BasePublicationInfo
      attr_accessor :issn, :title, :place_name, :place_of_publication, :language

      XML_NS = {
        dcterms: 'http://purl.org/dc/terms/',
        frbr: 'http://purl.org/vocab/frbr/core#',
        owl: 'http://www.w3.org/2002/07/owl#',
        rda: 'http://rdvocab.info/elements/',
        rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        rdfs: 'http://www.w3.org/2000/01/rdf-schema#'
      }.freeze

      BASE_URL = 'https://chroniclingamerica.loc.gov/lccn'.freeze

      def initialize(lccn)
        # true until loaded
        @empty = true
        super(lccn)
        @issn = nil # chronam doesn't have this
      end

      def empty?
        @empty
      end

      def inspect
        format(
          "<#{self.class}:0x000000000%<oid>x " \
            "\tlccn: '#{@lccn}'>",
          oid: object_id << 1
        )
      end

      def load_place
        @place_name = find('//rda:placeOfPublication').first.text
        @place_of_publication = NewspaperWorks::Ingest.geonames_place_uri(
          @place_name
        )
      end

      def url
        "#{BASE_URL}/#{@lccn}.rdf"
      end

      def load
        resp = Faraday.get url
        return if resp.status == 404
        @doc = Nokogiri.XML(resp.body)
        @title = find('//dcterms:title').first.text
        @language = iso_language_for(find('//dcterms:language').first.text)
        @empty = false
        load_place
      end

      def oclcnum
        key = 'info:oclcnum'
        selected = sameas_resources.select { |v| v.text.start_with?(key) }
        return if selected.empty?
        oclc_prefixed(selected[0].text.split('/')[1])
      end

      def preceded_by
        found = find('//frbr:successorOf/@rdf:resource')
        return if found.empty?
        normalize_related(found.first.text)
      end

      def succeeded_by
        found = find('//frbr:successor/@rdf:resource')
        return if found.empty?
        normalize_related(found.first.text)
      end

      private

        # Returns URL to LC catalog, provided such exists, on the basis of
        #   non-empty MODS for given LCCN.  Otherwise returns nil.
        def lc_catalog_url(lccn)
          content_url = "https://lccn.loc.gov/#{lccn}"
          url = "#{content_url}/mods"
          resp = Faraday.get url
          doc = Nokogiri.XML(resp.body)
          return content_url unless doc.root.children.empty?
        end

        def normalize_related(value)
          lccn = value.split('/')[-1].split('#')[0]
          lc_url = lc_catalog_url(lccn)
          # URL to lccn.loc.gov is preferred authority for publication URL
          return lc_url unless lc_url.nil?
          # URL to HTML representation of content on ChronAm is fallback
          "#{BASE_URL}/#{lccn}"
        end

        def sameas_resources
          find('//owl:sameAs/@rdf:resource')
        end

        def find(expr, context = nil)
          context ||= @doc
          context.xpath(expr, **XML_NS)
        end

        # ISO 639-2 three-character code from ISO 639-1 two-character code
        #   or equivalent lingvoj resource URL used by ChronAm;
        #   uses HTML language tables maintained by LOC.
        def iso_language_for(code)
          # handle case where source language code is lingvoj url:
          code = code.split('/')[-1]
          lookup_url = 'https://www.loc.gov/standards/iso639-2/php/langcodes_name.php'
          lookup_url += "?iso_639_1=#{code}"
          resp = Faraday.get lookup_url
          html = Nokogiri::HTML(resp.body)
          html.xpath('//table[1]/tr[2]/td[2]').first.text.strip
        end
    end
  end
end
