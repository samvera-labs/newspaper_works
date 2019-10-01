require 'open3'

module NewspaperWorks
  class ImageIdentifier
    attr_accessor :path, :ftype

    def initialize(path)
      @path = path
      @ftype = magic
      @metadata = nil
    end

    # @return [Hash] hash with following symbol keys, and respectively
    #   typed String and/or Integer values.
    #   :width, :height — both in Integer px units
    #   :color — (String enumerated from 'gray', 'monochrome', 'color')
    #   :num_components - Integer, number of channels
    #   :bits_per_component — Integer, bits per channel (e.g. 8 vs. 1)
    #   :content_type — RFC 2045 MIME type
    def metadata
      return @metadata unless @metadata.nil?
      @metadata = jp2? ? jp2_metadata : identify_metadata
    end

    # @return [String] RFC 2045 MIME type of image file at path
    def content_type
      metadata[:content_type]
    end

    # @return [Array(Integer, Integer)] two item array of width, height in px
    def geometry
      [metadata[:width], metadata[:height]]
    end

    # Return color system type.
    #   Is image gray (multi-bit), monochrome (one-bit), or color?
    # @return [String] one of 'gray', 'monochrome', 'color'
    def color_type
      metadata[:color]
    end

    private

      def jp2_metadata
        result = NewspaperWorks::JP2ImageMetadata.new(path).technical_metadata
        result[:content_type] = 'image/jp2'
        result
      end

      def im_line_select(lines, key)
        line = lines.select { |l| l.downcase.strip.start_with?(key) }[0]
        # Given "key: value" line, return the value as String stripped of
        #   leading and trailing whitespace
        return line if line.nil?
        line.strip.split(':')[-1].strip
      end

      # @return [Array(Integer, Integer)] width, height in Integer px units
      def im_identify_geometry(lines)
        img_geo = im_line_select(lines, 'geometry').split('+')[0]
        img_geo.split('x').map(&:to_i)
      end

      # @return [Array<String>] lines of output from imagemagick `identify`
      def im_identify
        cmd = "identify -verbose #{path}"
        `#{cmd}`.lines
      end

      def populate_im_color!(lines, result)
        bpc = im_line_select(lines, 'depth').split('-')[0].to_i # '1-bit' -> 1
        colorspace = im_line_select(lines, 'colorspace')
        color = colorspace == 'Gray' ? 'gray' : 'color'
        has_alpha = !im_line_select(lines, 'Alpha').nil?
        result[:num_components] = (color == 'gray' ? 1 : 3) + (has_alpha ? 1 : 0)
        result[:color] = bpc == 1 ? 'monochrome' : color
        result[:bits_per_component] = bpc
      end

      # Return metadata by means of imagemagick identify
      def identify_metadata
        result = {}
        lines = im_identify
        result[:width], result[:height] = im_identify_geometry(lines)
        result[:content_type] = im_line_select(lines, 'mime type')
        populate_im_color!(lines, result)
        result
      end

      def magic
        File.read(@path, 23, 0)
      end

      def jp2?
        @ftype.end_with?('ftypjp2')
      end
  end
end
