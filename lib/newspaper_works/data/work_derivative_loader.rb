require 'hyrax'

module NewspaperWorks
  module Data
    class WorkDerivativeLoader
      # mapping of special names Hyrax uses for derivatives, not extension:
      @remap_names = {
        'jpeg' => 'thumbnail'
      }
      class << self
        attr_accessor :remap_names
      end

      def initialize(work)
        # context usually work, may be FileSet, may be string id of FileSet
        @context = work
        # computed name-to-path mapping, initially nil as sentinel for JIT load
        @paths = nil
      end

      # Load all paths/names to @paths once, upon first access
      def load_paths
        # list of paths
        paths = path_factory.derivatives_for_reference(fileset_id)
        # names from paths
        @paths = paths.map { |e| [path_destination_name(e), e] }.to_h
      end

      def path_destination_name(path)
        ext = path.split('.')[-1]
        self.class.remap_names[ext] || ext
      end

      def respond_to_missing?(symbol, include_priv = false)
        {}.respond_to?(symbol, include_priv)
      end

      def method_missing(method, *args, &block)
        # if we proxy mapping/hash enumertion methods,
        #   make sure @paths loaded, then proxy to it.
        if respond_to_missing?(method)
          load_paths if @paths.nil?
          return @paths.send(method, *args, &block)
        end
        super
      end

      def path_factory
        Hyrax::DerivativePath
      end

      def fileset_id
        # if context is itself a string, presume it is a file set id
        return @context if @context.class == String
        # context might be a FileSet...
        return @context if @context.class == FileSet
        # ...or a work:
        filesets = @context.members.select { |m| m.class == FileSet }
        filesets.empty? ? nil : filesets[0].id
      end

      def path(name)
        load_paths if @paths.nil?
        result = @paths[name]
        return if result.nil?
        File.exist?(result) ? result : nil
      end

      def with_io(name, &block)
        filepath = path(name)
        return if filepath.nil?
        File.open(filepath, 'rb', &block)
      end

      def data(name)
        result = ''
        with_io(name) do |io|
          result += io.read
        end
        result
      end
    end
  end
end
