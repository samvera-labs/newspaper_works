module NewspaperWorks
  module Data
    # Mixin module for fileset methods for work, presumes an @work
    #   instance attribute refering to a work object
    module FilesetHelper
      def fileset_id
        # if context is itself a string, presume it is a file set id
        return @work if @work.class == String
        # if context is not a String, presume a work or fileset context:
        fileset = work_fileset
        fileset.nil? ? nil : fileset.id
      end

      def work_fileset
        return @work if @work.class == FileSet
        filesets = @work.members.select { |m| m.class == FileSet }
        filesets.empty? ? nil : filesets[0]
      end

      # if work context has no file set, create one
      def ensure_fileset_exists
        return if @work.class == FileSet
        fileset = work_fileset
        return unless fileset.nil?
        # if no fileset, create an empty one
        fileset = FileSet.new
        fileset.save!(validate: false)
        @work.members.push(fileset)
      end
    end
  end
end
