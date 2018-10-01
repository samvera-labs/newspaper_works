require 'nokogiri'

module NewspaperWorks
  # Module for text extraction
  module TextExtraction
    class AltoReader
      def initialize(xml)
        @source = isxml?(xml) ? xml : File.read(xml)
        @doc = Nokogiri::XML(output).remove_namespaces!
      end

      def isxml?(xml)
        xml.lstrip.start_with?('<')
      end

      def as_json
        words = @doc.xpath('//String').to_a.map do |token|
          {
            word: s_txt(token),
            coords: s_coords(token)
          }
        end
        words
      end

      def s_txt(e)
        e.attr('CONTENT')
      end

      def s_coords(e)
        height = (e.attr('HEIGHT') || 0).to_i
        width = (e.attr('WIDTH') || 0).to_i
        hpos = (e.attr('HPOS') || 0).to_i
        vpos = (e.attr('VPOS') || 0).to_i
        [hpos, vpos, width, height]
      end

      def as_plain_text
        text = ''
        @doc.xpath('//TextBlock').to_a.each do |block|
          block.xpath('//TextLine').to_a.each do |line|
            text += line.xpath('//String').map { |e| s_txt(e) }.join(' ')
            text += '\n'
          end
          text += '\n'
        end
        text
      end
    end
  end
end
