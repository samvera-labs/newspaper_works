require 'uri'

module NewspaperWorks
  module Data
    class WorkFiles
      attr_accessor :work, :assigned, :unassigned
      delegate :include?, to: :keys

      # alternate constructor spelling:
      def self.of(work)
        new(work)
      end

      def initialize(work)
        @work = work
        @assigned = []
        @unassigned = []
      end

      def derivatives
        # TODO: implement this access to WorkDerivatives
      end

      def state
        return 'empty' if @assigned.empty? && keys.empty?
        return 'dirty' unless @assigned.empty?
        # TODO: implement 'pending' as intermediate state between 'dirty'
        #   and saved, where we look for saved state that matches what was
        #   previously assigned in THIS instance.  We can only know that
        #   changes initiated by this instance in this thread are pending
        #   because there's no global storage for the assignment queue.
        'saved'
      end

      def keys
        filesets.map(&:id)
      end

      def values
        keys.map(&method(:get))
      end

      def entries
        filesets.map { |fs| [fs.id, self[fs.id]] }
      end

      # List of local file names for attachments, based on original ingested
      #   or uploaded file name.
      # @return [Array<String>]
      def names
        filesets.map(&method(:original_name))
      end

      def get(name_or_id)
        return get_by_fileset_id(name_or_id) if keys.include?(name_or_id)
        get_by_filename(name_or_id)
      end

      def assign(path)
        path = normalize_path(path)
        validate_path(path)
        @assigned.push(path)
      end

      def unassign(name_or_id)
        # if name_or_id is queued path, remove from @assigned queue:
        @assigned.delete(name_or_id) if @assigned.include?(name_or_id)
        # if name_or_id is known id or name, remove
        @unassigned.push(name_or_id) if include?(name_or_id)
      end

      # commit pending changes to work files
      #   beginning with removals, then with new assignments
      def commit!
        commit_unassigned
        commit_assigned
      end

      alias [] :get

      private

        def get_by_fileset_id(id)
          nil unless keys.include?(id)
          fileset = FileSet.find(id)
          NewspaperWorks::Data::WorkFile.of(work, fileset, self)
        end

        # Get one WorkFile object based on filename in metadata
        def get_by_filename(name)
          r = filesets.select { |fs| original_name(fs) == name }
          # checkout first match
          r.empty? ? nil : NewspaperWorks::Data::WorkFile.of(work, r[0], self)
        end

        def normalize_path(path)
          path = path.to_s
          isuri?(path) ? path : File.expand_path(path)
        end

        def isuri?(path)
          !path.scan(URI.regexp).empty?
        end

        def path_to_uri(path)
          isuri?(path) ? path : "file://#{path}"
        end

        def validate_path(path)
          # treat file URIs equivalent to local paths
          path = File.expand_path(path.sub(/^file:\/\//, ''))
          # make sure file exists
          raise IOError, "Not found: #{path}" unless File.exist?(path)
        end

        def original_name(fileset)
          fileset.original_file.original_name
        end

        def filesets
          # file sets with non-nil original file contained:
          work.members.select { |m| m.class == FileSet && m.original_file }
        end

        def user
          defined?(current_user) ? current_user : User.batch_user
        end

        def ensure_depositor
          return unless @work.depositor.nil?
          @work.depositor = user.user_key
        end

        def commit_unassigned
          # for each (name or) id to be removed from work, use actor to destroy
          @unassigned.each do |id|
            # "actor" here is simply a multi-adapter of Fileset, User
            # Calling destroy will:
            #   1. unlink fileset from work, and save work
            #   2. Destroy fileset:
            #     - :before_destroy callback will delegate derivative cleanup
            #       to derivatives service component(s).
            #     - Remove fileset from storage/persistence layers
            #     - Invoke (logging or other) :after_destroy callback
            Hyrax::Actors::FileSetActor.new(get(id).fileset, user).destroy
          end
        end

        def commit_assigned
          return if @assigned.nil? || @assigned.empty?
          ensure_depositor
          remote_files = @assigned.map do |path|
            { url: path_to_uri(path), file_name: File.basename(path) }
          end
          attrs = { remote_files: remote_files }
          # Create an environment for actor stack:
          env = Hyrax::Actors::Environment.new(@work, Ability.new(user), attrs)
          # Invoke default Hyrax actor stack middleware:
          Hyrax::CurationConcern.actor.create(env)
        end
    end
  end
end
