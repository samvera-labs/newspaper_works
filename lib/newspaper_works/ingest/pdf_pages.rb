require 'open3'
require 'securerandom'
require 'tmpdir'

module NewspaperWorks
  module Ingest
    class PdfPages
      include Enumerable

      def initialize(path)
        @baseid = SecureRandom.uuid
        @pdfpath = path
        @info = nil
        @entries = nil
        @tmpdir = nil
        @size = nil
        @pagecount = nil
        @pdftext = nil
      end

      # return
      def pdfinfo
        @info = PdfImages.new(@pdfpath) if @info.nil?
        @info
      end

      def tmpdir
        @tmpdir = Dir.mktmpdir if @tmpdir.nil?
        @tmpdir
      end

      def colordevice(channels, bpc)
        bits = bpc * channels
        # will be either 8bpc/16bpd color TIFF,
        #   with any CMYK source transformed to 8bpc RBG
        bits = 24 unless [24, 48].include? bits
        "tiff#{bits}nc"
      end

      def gsdevice
        color, channels, bpc = pdfinfo.color
        device = nil
        # CCITT Group 4 Black and White, if applicable:
        device = 'tiffg4' if color == 'gray' && bpc == 1
        # 8 Bit Grayscale, if applicable:
        device = 'tiffgray' if color == 'gray' && bpc > 1
        # otherwise color:
        device = colordevice(channels, bpc) if device.nil?
        device
      end

      def gstext
        cmd = "gs -dNOPAUSE -dBATCH -sDEVICE=txtwrite " \
              "-sOutputFile=- -f #{@pdfpath}"
        # rubocop:disable Lint/UnusedBlockArgument
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          @pdftext = stdout.read
        end
        # rubocop:enable Lint/UnusedBlockArgument
        @pdftext
      end

      def pagecount
        cmd = "pdfinfo #{@pdfpath}"
        # rubocop:disable Lint/UnusedBlockArgument
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          output = stdout.read.split("\n")
          pages_e = output.select { |e| e.start_with?('Pages:') }[0]
          @pagecount = pages_e.split[-1].to_i
        end
        # rubocop:enable Lint/UnusedBlockArgument
        @pagecount
      end

      def ppi
        imageppi = pdfinfo.ppi
        if imageppi < 300
          # check text to see if this looks like it is not scanned media
          #   and defer to minimum 400ppi if necessary.
          text = gstext
          return 400 if (text.length / pagecount.to_f) > 160
        end
        imageppi
      end

      # ghostscript convert all pages to TIFF
      def gsconvert
        output_base = File.join(tmpdir, "#{@baseid}-page%d.tiff")
        cmd = "gs -dNOPAUSE -dBATCH -sDEVICE=#{gsdevice} " \
              "-dTextAlphaBits=4 " \
              "-sOutputFile=#{output_base} -r#{ppi} -f #{@pdfpath}"
        # rubocop:disable Lint/UnusedBlockArgument
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          output = stdout.read.split("\n")
          @size = output.select { |e| e.start_with?('Page ') }.length
        end
        # rubocop:enable Lint/UnusedBlockArgument
        # Return an array of expected filenames
        (1..@size).map { |n| File.join(tmpdir, "#{@baseid}-page#{n}.tiff") }
      end

      # entries for each page
      def entries
        @entries = gsconvert if @entries.nil?
        @entries
      end

      def each
        entries.each do |e|
          yield(e)
        end
      end
    end
  end
end
