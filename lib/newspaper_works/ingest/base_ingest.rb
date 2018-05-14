module NewspaperWorks
  module Ingest
    # base class for ingesting works, implements, as-needed, temp files
    class BaseIngest
      def initialize(work)
        # adapted context:
        @work = work
      end

      def loadpath(source)
        # quick check the file exists and is readable on filesystem:
        raise ArgumentError, 'File not found or readable' unless
          File.readable?(source)
        # path may be relative to Dir.pwd, but no matter for our use
        @path = source
        @io = File.open(source)
        @filename ||= File.split(source)[-1]
      end

      def loadio(source)
        # either an IO with a path, or an IO with filename passed in
        #   args; presume we need a filename to describe/identify.
        raise ArgumentError, 'Explicit or inferred file name required' unless
          source.respond_to?('path') || @filename
        @io = source
        @filename ||= source.path
      end

      def ingest(source, filename: nil)
        # source is a string (path) or source is an IO
        unless source.class == String ||
               source.respond_to?('read')
          raise ArgumentError, 'Source is neither string (path) nor IO object'
        end
        # permit the possibility of a filename identifier metadata distinct
        #   from the actual path on disk:
        @filename = filename
        loader = source.class == String ? method(:loadpath) : method(:loadio)
        loader.call(source)
        handle_file
      end

      # default handler attaches file to work's file set, subclasses
      #   may overwride or wrap this.
      def handle_file
        # read file data and add it to file set on work
      end
    end
  end
end
