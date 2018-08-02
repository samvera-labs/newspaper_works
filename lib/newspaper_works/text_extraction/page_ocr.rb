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

      # TODO: moved ALTO generation to its own class
      def alto; end
    end
  end
end
