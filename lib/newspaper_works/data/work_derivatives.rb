require 'hyrax'

module NewspaperWorks
  module Data
    # Disable below metric, for now, not splitting this class into modules,
    #   which would just make for more complexity and hinder readabilty.
    #   TODO: consider compositional refactoring (not mixins), but this
    #         may make readability/comprehendability higher, and yield
    #         higher applied/practical complexity.
    # rubocop:disable Metrics/ClassLength
    class WorkDerivatives
      include NewspaperWorks::Data::FilesetHelper
      include NewspaperWorks::Data::PathHelper

      attr_accessor :work, :fileset

      # mapping of special names Hyrax uses for derivatives, not extension:
      @remap_names = {
        'jpeg' => 'thumbnail'
      }
      class << self
        attr_accessor :remap_names
      end

      def initialize(work, fileset: nil)
        # adapted context usually work, may be string id of FileSet
        @work = work
        @fileset = fileset.nil? ? first_fileset : fileset
        # computed name-to-path mapping, initially nil as sentinel for JIT load
        @paths = nil
        # assignments for attachment
        @assigned = []
        # un-assignments for deletion
        @unassigned = []
      end

      def state
        return 'empty' if @assigned.empty? && @paths.keys.empty?
        return 'dirty' unless @assigned.empty?
        'saved'
      end

      def assign(path)
        path = normalize_path(path)
        validate_path(path)
        @assigned.push(path)
      end

      def unassign(name)
        # if name is queued path, remove from @assigned queue:
        @assigned.delete(name) if @assigned.include?(name)
        # if name is known destination name, remove
        @unassigned.push(name) if exist?(name)
      end

      def commit!
        @unassigned.each { |name| delete(name) }
        @assigned.each do |path|
          attach(path, path_destination_name(path))
        end
        # reset queues after work is complete
        @assigned = []
        @unassigned = []
      end

      def attach(file, name)
        mkdir_pairtree
        path = path_factory.derivative_path_for_reference(fileset, name)
        # if file argument is path, copy file
        if file.class == String
          FileUtils.copy(file, path)
        else
          # otherwise, presume file is an IO, read, write it
          #   note: does not close input file/IO, presume that is caller's
          #   responsibility.
          orig_pos = file.tell
          file.seek(0)
          File.open(path, 'w') { |dstfile| dstfile.write(file.read) }
          file.seek(orig_pos)
        end
        # finally, reload @paths after mutation
        load_paths
      end

      def delete(name, force: nil)
        path = path_factory.derivative_path_for_reference(fileset, name)
        # will remove file, if it exists; won't remove pairtree, even
        #   if it becomes empty, as that is excess scope.
        FileUtils.rm(path, force: force) if File.exist?(path)
        # finally, reload @paths after mutation
        load_paths
      end

      def path(name)
        load_paths if @paths.nil?
        result = @paths[name]
        return if result.nil?
        File.exist?(result) ? result : nil
      end

      def with_io(name, &block)
        mode = ['xml', 'txt', 'html'].include?(name) ? 'rb:UTF-8' : 'rb'
        filepath = path(name)
        return if filepath.nil?
        File.open(filepath, mode, &block)
      end

      def size(*args)
        load_paths if @paths.nil?
        return @paths.size if args[0].nil?
        File.size(@paths[args[0]])
      end

      def exist?(name)
        keys.include?(name) && File.exist?(self[name])
      end

      def data(name)
        result = ''
        with_io(name) do |io|
          result += io.read
        end
        result
      end

      private

        # Load all paths/names to @paths once, upon first access
        def load_paths
          fsid = fileset_id
          if fsid.nil?
            @paths = {}
            return
          end
          # list of paths
          paths = path_factory.derivatives_for_reference(fsid)
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

        # make shared path for derivatives to live, given
        def mkdir_pairtree
          # Hyrax::DerivativePath has no public method to directly get the
          #   bare pairtree path for derivatives for a fileset, but we
          #   can infer it...
          path = path_factory.derivative_path_for_reference(fileset, '')
          dir = File.join(path.split('/')[0..-2])
          FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
        end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
