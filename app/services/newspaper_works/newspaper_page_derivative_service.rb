module NewspaperWorks
  # Base type for derivative services specific to NewspaperPage only
  class NewspaperPageDerivativeService
    attr_reader :file_set, :master_format
    delegate :uri, to: :file_set

    TARGET_EXT = nil

    def self.target_ext
      self::TARGET_EXT
    end

    def initialize(file_set)
      @file_set = file_set
      @dest_path = nil
      @source_path = nil
      @source_meta = nil
    end

    def valid?
      parent = file_set.in_works[0]
      # fallback to Fedora-stored relationships if work's aggregation of
      #   file set is not indexed in Solr
      parent = file_set.member_of.select(&:work?)[0] if parent.nil?
      parent.class == NewspaperPage
    end

    def derivative_path_factory
      Hyrax::DerivativePath
    end

    # prepare full path for passed extension/destination name, return path
    def prepare_path(extension)
      dest_path = derivative_path_factory.derivative_path_for_reference(
        @file_set,
        extension
      )
      dir = File.join(dest_path.split('/')[0..-2])
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      dest_path
    end

    # calculate and ensure directory components for singular @dest_path
    #   should only be used by subclasses producing a single derivative
    def load_destpath
      @dest_path = prepare_path(self.class.target_ext)
    end

    def identify
      return @source_meta unless @source_meta.nil?
      @source_meta = NewspaperWorks::ImageTool.new(@source_path).metadata
    end

    def mime_type
      identify[:content_type]
    end

    def use_color?
      identify[:color] == 'color'
    end

    # is source one-bit monochrome?
    def one_bit?
      identify[:color] == 'monochrome'
    end

    def create_derivatives(filename)
      # presuming that filename is full path to source file
      @source_path = filename

      # Get destination path from Hyrax for file extension defined in
      #   TARGET_EXT constant on respective derivative service subclass.
      load_destpath
    end

    def cleanup_derivatives(*args)
      target_ext = args && args[0] ? args[0] : self.class.target_ext
      derivative_path_factory.derivatives_for_reference(file_set).each do |path|
        FileUtils.rm_f(path) if path.ends_with?(target_ext)
      end
    end

    def jp2_to_intermediate
      intermediate_path = File.join(Dir.mktmpdir, 'intermediate.tif')
      jp2_cmd = "opj_decompress -i '#{@source_path}' -o #{intermediate_path}"
      # make intermediate, then...
      `#{jp2_cmd}`
      intermediate_path
    end

    def convert_cmd
      raise NotImplementedError, 'Calling subclass missing convert_cmd method'
    end

    # convert non-JP2 source/primary file to PDF derivative with ImageMagick6
    #   calls convert_cmd on calling subclasses
    def im_convert
      `#{convert_cmd}`
    end

    # convert JP2 source/primary file to PDF derivative, via
    #   opj_decompress to intermediate TIFF, then ImageMagick6 convert
    def jp2_convert
      # jp2 source -> intermediate
      intermediate_path = jp2_to_intermediate
      @source_path = intermediate_path
      # intermediate -> PDF
      im_convert
    end

    # def cleanup_derivatives; end
  end
end
