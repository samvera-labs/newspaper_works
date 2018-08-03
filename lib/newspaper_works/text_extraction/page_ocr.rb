require 'open3'
require 'rtesseract'

# --
module NewspaperWorks
  # Module for text extraction (OCR or otherwise)
  module TextExtraction
    class PageOCR
      def self.alto_from(path)
        new(path).alto
      end

      def initialize(path)
        @filepath = path
        @words = nil
        @processor = "mini_magick"
        @source_meta = nil
        @use_gm = false
      end

      def extension
        @filepath.split('.')[-1].downcase
      end

      # configure this component, based on source
      def config!
        # do not use mini_magick preprocess on TIFF, instead RTesseract
        #   will use a processor that merely copies it to tempfile
        @processor = 'none' if extension.start_with?('tif')
        @use_gm = extension.start_with?('jp2')
      end

      def load_words
        @words = RTesseract::Box.new(@filepath, processor: @processor)
      end

      def words
        if @words.nil?
          config!
          if @use_gm
            MiniMagick.with_cli(:graphicsmagick) do
              load_words
            end
          else
            load_words
          end
        end
        @words
      end

      def identify
        if @source_geometry.nil?
          path = @filepath
          cmd = "identify -verbose #{path}"
          cmd = 'gm ' + cmd if @use_gm
          lines = `#{cmd}`.lines
          geo = lines.select { |line| line.strip.start_with?('Geometry') }[0]
          img_geo = geo.strip.split(':')[-1].strip.split('+')[0]
          @source_geometry = img_geo.split('x').map(&:to_i)
        end
        @source_geometry
      end

      def width
        identify[0]
      end

      def height
        identify[1]
      end

      def alto
        writer = NewspaperWorks::TextExtraction::RenderAlto.new(width, height)
        writer.to_alto(words)
      end
    end
  end
end
