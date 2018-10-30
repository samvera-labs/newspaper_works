# encoding=utf-8

require 'hyrax'

module NewspaperWorks
  module Data
    class WorkFile
      include NewspaperWorks::Data::FilesetHelper

      attr_accessor :work, :io, :filename

      def initialize(work)
        @work = work
        # below set to non-nil values on call of .prepare_source via .attach
        @io = nil
        @source_path = nil
        @working_path = nil
        @filename = nil
        # fileset initially nil, if no file attached; accessors may cache
        #   fileset on any applicable operation
        @fileset = nil
      end

      def attach(file, filename: nil, queue: true, single: true)
        delete if single
        prepare_source(file, filename: filename)
        # work must have depositor for AttachFilesToWorkJob
        ensure_depositor
        upload = Hyrax::UploadedFile.create(file: @io)
        # Note: if attach is asynchronous, creating an @fileset reference
        #   afterward is impractical, so caching defered to subsequent access
        job = AttachFilesToWorkJob
        queue ? job.perform_later(@work, [upload]) : job.perform_now(@work, [upload])
      end

      def delete
        load_fileset
        return if @fileset.nil?
        # FileSetActor-triggered callbacks need user;
        #   make one that works in browser and non-browser contexts:
        user = defined?(current_user) ? current_user : User.batch_user
        # via Hyrax, remove fileset, clean solr cruft, notify :after_destroy
        Hyrax::Actors::FileSetActor.new(@fileset, user).destroy
        # set sentinel for empty:
        @fileset = nil
      end

      def data
        fetch_working_copy
        File.read(@working_path)
      end

      def path
        fetch_working_copy
        @working_path
      end

      def exist?
        load_fileset
        @fileset && @fileset.original_file
      end

      def size
        load_fileset
        @fileset.original_file.size
      end

      private

        def ensure_depositor
          return unless @work.depositor.nil?
          user = defined?(current_user) ? current_user : User.batch_user
          @work.depositor = user.user_key
        end

        def load_fileset
          return @fileset unless @fileset.nil?
          # NewspaperWorks::FilesetHelper.work_fileset gets, but does not
          #   cache; also presumes single-file work.
          @fileset = work_fileset
        end

        def fetch_working_copy
          return unless @working_path.nil? && File.exist?(@working_path)
          # presumes single-file work, with single primary file stored in
          #   fileset
          load_fileset
          fsid = @fileset.id
          fileid = @fileset.original_file.id
          @working_path = Hyrax::WorkingPath.find_or_retrieve(fileid, fsid)
        end

        def prepare_source_path(source)
          # quick check the file exists and is readable on filesystem:
          raise ArgumentError, 'File not found or readable' unless
            File.readable?(source)
          # path may be relative to Dir.pwd, but no matter for our use
          @source_path = source.to_s
          @io = File.open(@source_path)
          @filename ||= File.split(@source_path)[-1]
        end

        def prepare_source_io(source)
          # either an IO with a path, or an IO with filename passed in
          #   args; presume we need a filename to describe/identify.
          raise ArgumentError, 'Explicit or inferred file name required' unless
            source.respond_to?('path') || @filename
          @io = source
          @source_path = source.respond_to?('path') ? source.path : nil
          @filename ||= File.split(@source_path)[-1]
        end

        def prepare_source(source, filename: nil)
          # source is a string path, Pathname object, or quacks like an IO
          unless source.class == String ||
                 source.class == Pathname ||
                 source.respond_to?('read')
            raise ArgumentError, 'Source is neither path nor IO object'
          end
          # permit the possibility of a filename identifier metadata distinct
          #   from the actual path on disk:
          @filename = filename
          ispath = source.class == String || source.class == Pathname
          loader = ispath ? method(:prepare_source_path) : method(:prepare_source_io)
          loader.call(source)
        end
    end
  end
end
