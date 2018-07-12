require 'open3'

module NewspaperWorks
  # OpenJPEG 2000 Command to make NDNP-compliant grayscale JP2:
  CMD_GRAY = 'opj_compress -i %<source_file>s -o %<out_file>s ' \
             '-d 0,0 -b 64,64 -n 6 -p RLCP -t 1024,1024 -I -M 1 ' \
             '-r 64,53.821,45.249,40,32,26.911,22.630,20,16,14.286,' \
             '11.364,10,8,6.667,5.556,4.762,4,3.333,2.857,2.500,2,' \
             '1.667,1.429,1.190,1'.freeze

  # OpenJPEG 2000 Command to make RGB JP2:
  CMD_COLOR = 'opj_compress -i %<source_file>s -o %<out_file>s ' \
              '-d 0,0 -b 64,64 -n 6 -p RPCL -t 1024,1024 -I -M 1 '\
              '-r 2.4,1.48331273,.91673033,.56657224,.35016049,.21641118,' \
              '.13374944,.0944,.08266171'.freeze

  # OpenJPEG 1.x command replacement for 2.x opj_compress, takes same options;
  #   this is necessary on Ubuntu Trusty (e.g. Travis CI)
  CMD_1X = 'image_to_j2k'.freeze

  class JP2DerivativeService < NewspaperPageDerivativeService
    attr_accessor :source_meta
    attr_reader :file_set
    delegate :uri, :mime_type, to: :file_set

    def initialize(file_set)
      # cached result string for imagemagick `identify` command
      @source_meta = nil
      @command = nil
      @source_path = nil
      @dest_path = nil
      @unlink_after_creation = []
      super(file_set)
    end

    def create_derivatives(filename)
      @source_path = filename

      # no creation if jp2 master => deemed unnecessary/duplicative
      return if mime_type == 'image/jp2'

      # if we have a non-TIFF source, or a 1-bit monochrome source, we need
      #   to make a NetPBM-based intermediate (temporary) file for OpenJPEG
      #   to consume.
      needs_intermediate = !tiff_source? || one_bit?

      # We use either intermediate temp file, or temp symlink (to work
      #   around OpenJPEG 2000 file naming quirk).
      needs_intermediate ? make_intermediate_source : make_symlink

      # Get destination path from Hyrax for 'jp2' destination name:
      @dest_path = derivative_path_factory.path_for_reference(@file_set, 'jp2')

      # Get OpenJPEG command, rendered with source, destination, appropriate
      #   to either color or grayscale source
      render_cmd = opj_command

      # Run the generated command to make derivative file at @dest_path
      `#{render_cmd}`

      # Clean up any intermediate files or symlinks used during creation
      cleanup_intermediate
    end

    def cleanup_derivatives
      derivative_path_factory.derivatives_for_reference(file_set).each do |path|
        FileUtils.rm_f(path) if path.ends_with?('jp2')
      end
    end

    private

      # source introspection:

      def identify
        if @source_meta.nil?
          path = @source_path
          # rubocop:disable Lint/UnusedBlockArgument
          Open3.popen3("identify #{path}") do |stdin, stdout, stderr, wait_thr|
            @source_meta = stdout.read
          end
          # rubocop:enable Lint/UnusedBlockArgument
        end
        @source_meta
      end

      def tiff_source?
        identify.include?('TIFF')
      end

      def use_color?
        # imagemagick `identify` output describes color space:
        identify.include?('sRGB') || identify.include?('CMYK')
      end

      # is source one-bit monochrome?
      def one_bit?
        identify.include?('1-bit')
      end

      def make_symlink
        # OpenJPEG binaries have annoying quirk of only using TIFF input
        #   files whose name ends in .TIF or .tif (three letter); for all
        #   non-monochrome TIFF files, we just assume we need to symlink
        #   to such a filename.
        tmpname = File.join(Dir.tmpdir, '#{SecureRandom.uuid}.tif')
        FileUtils.ln_s(@source_path, tmpname)
        @unlink_after_creation.push(tmpname)
        # finally, point @source_path for command at intermediate link:
        @source_path = tmpname
      end

      def make_intermediate_source
        ext = use_color? ? 'ppm' : 'pgm'
        # generate a random filename to be made, with appropriate extension,
        #   inside /tmp dir:
        tmpname = File.join(
          Dir.tmpdir,
          format(
            '#{SecureRandom.uuid}.%<ext>s',
            ext: ext
          )
        )
        # Use ImageMagick `convert` to create intermediate bitmap:
        `convert #{@source_path} #{tmpname}`
        @unlink_after_creation.push(tmpname)
        # finally, point @source_path for command at intermediate file:
        @source_path = tmpname
      end

      def opj_command
        # Get a command template appropriate to OpenJPEG 1.x or 2.x
        use_openjpeg_1x = `which opj_compress`.empty?
        cmd = use_color? ? CMD_COLOR : CMD_GRAY
        cmd = cmd.sub('opj_compress', 'image_to_j2k') if use_openjpeg_1x
        # return command with source and destination file names injected
        format(
          cmd,
          source_file: @source_path,
          dest_file: @dest_path
        )
      end

      def derivative_path_factory
        Hyrax::DerivativePath
      end

      def cleanup_intermediate
        # remove symlink or intermediate file once we no longer need
        @unlink_after_creation.each do |path|
          FileUtils.rm(path)
        end
      end
  end
end
