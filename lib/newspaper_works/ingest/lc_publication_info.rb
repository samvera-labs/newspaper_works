require 'faraday'
require 'nokogiri'
require 'uri'

module NewspaperWorks
  module Ingest
    class LCPublicationInfo < BasePublicationInfo
      attr_accessor :place_of_publication, :full_title, :lccn, :place_name, :doc

      XML_NS = {
        mods: 'http://www.loc.gov/mods/v3',
        MODS: 'http://www.loc.gov/mods/v3'
      }.freeze

      BASE_URL = 'https://lccn.loc.gov'.freeze

      def initialize(lccn)
        super(lccn)
        @doc = nil
        @full_title = nil
        @place_of_publication = nil
        @place_name = nil
        load
      end

      def inspect
        format(
          "<#{self.class}:0x000000000%<oid>x " \
            "\tlccn: '#{@lccn}'>",
          oid: object_id << 1
        )
      end

      def url
        "#{BASE_URL}/#{@lccn}/mods"
      end

      def load_lc
        resp = Faraday.get url
        @doc = Nokogiri.XML(resp.body)
        return if empty?
        # try title[@type="uniform"] first:
        title = find('//mods:titleInfo[@type="uniform"]/mods:title').first
        # if no type="uniform" title, try non-alternate bare titleInfo:
        #   -- in either case, should omit any non-sorted article (e.g. "The")
        title = find('//mods:titleInfo[count(@type)=0]/mods:title').first if title.nil?
        @full_title = title.text unless title.nil?
      end

      def load_place
        place_term = find('//mods:originInfo//mods:placeTerm[@type="text"]').first
        @place_name = place_term.nil? ? nil : place_term.text
        @place_name = place_name_from_title(@full_title) if @place_name.nil?
        return if @place_name.nil?
        uri = NewspaperWorks::Ingest.geonames_place_uri(@place_name)
        @place_of_publication = uri
      end

      def empty?
        @doc.nil? || @doc.root.children.empty?
      end

      def load
        load_lc
        load_place unless @full_title.nil?
      end

      def title
        return if empty?
        @full_title.split(/ [\(]/)[0]
      end

      # ISO-639-2 three character language code, default is 'eng' (English)
      def language(default = 'eng')
        return if empty?
        v = find('//mods:language/mods:languageTerm').first
        v.nil? ? default : v.text
      end

      def issn
        return if empty?
        v = find('//mods:mods/mods:identifier[@type="issn"]').first
        v.nil? ? nil : v.text
      end

      def oclcnum
        return if empty?
        v = find('//mods:mods/mods:identifier[@type="oclc"]').first
        v.nil? ? nil : oclc_prefixed(v.text)
      end

      def preceded_by
        related_by('preceding')
      end

      def succeeded_by
        related_by('succeeding')
      end

      private

        def related_by(key)
          return if empty?
          v = find("//mods:relatedItem[@type='#{key}']")
          return nil if v.empty?
          lccn = lccn_for(v[0])
          return "#{BASE_URL}/#{lccn}" unless lccn.nil?
          # No LCCN, ergo no URL, but a related item with a literal title?
          titles = find('mods:title', v[0])
          titles.empty? ? nil : titles[0].text
        end

        def lccn_for(related_item)
          identifiers = find('mods:identifier[@type="local"]', related_item)
          selected = identifiers.select { |v| v.text.start_with?('(DLC)') }
          return if selected.size.zero?
          selected.first.text.split(')')[-1].sub(' ', '')
        end

        def find(expr, context = nil)
          context ||= @doc
          context.xpath(
            expr,
            **XML_NS
          )
        end
    end
  end
end