require 'open3'

module NewspaperWorks
  module Ingest
    class PdfImages
      def initialize(path)
        @path = path
        @cmd = format('pdfimages -list %<path>s', path: path)
        @output = nil
        @entries = nil
      end

      def process
        # call just once
        if @output.nil?
          # rubocop:disable Lint/UnusedBlockArgument
          Open3.popen3(@cmd) do |stdin, stdout, stderr, wait_thr|
            @output = stdout.read.split("\n")
          end
          # rubocop:enable Lint/UnusedBlockArgument
        end
        @output.slice(2, @output.size - 1)
      end

      def entries
        if @entries.nil?
          @entries = []
          output = process
          (0..output.size - 1).each do |i|
            @entries.push(output[i].gsub(/\s+/m, ' ').strip.split(" "))
          end
        end
        @entries
      end

      def first
        entries[0]
      end

      def width
        first[3].to_i
      end

      def height
        first[4].to_i
      end

      def color
        # desc is either 'gray' or 'color', but 1-bit gray is black/white
        #   so caller may want all of this information, and in case of
        #   mixed color spaces across images, this returns maximum
        desc = entries.any? { |e| e[5] == 'color' } ? 'color' : 'gray'
        channels = entries.map { |e| e[6].to_i }.max
        bits = entries.map { |e| e[7].to_i }.max
        [desc, channels, bits]
      end
    end
  end
end
