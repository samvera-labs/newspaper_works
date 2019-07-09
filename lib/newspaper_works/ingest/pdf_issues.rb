module NewspaperWorks
  module Ingest
    class PDFIssues
      include Enumerable

      attr_accessor :path, :publication, :pdf_paths

      def initialize(path, publication)
        @path = path
        # as a NewspaperWorks::Ingest::PublicationInfo object:
        @publication = publication
        @pdf_paths = valid_pdfs(path)
      end

      def valid_pdfs(path)
        target = []
        Find.find(path) do |p|
          next if File.directory?(p)
          next unless p.end_with?('.pdf')
          target.push(p)
        end
        target
      end

      def lccn
        @publication.lccn
      end

      def info(path)
        NewspaperWorks::Ingest::PDFIssue.new(path)
      end

      def each
        @pdf_paths.each do |path|
          yield [path, info(path)]
        end
      end

      def each_key
        @pdf_paths.each
      end

      def each_value
        @pdf_paths.each do |path|
          yield info(path)
        end
      end

      def values
        each_value.to_a
      end

      def entries
        each.to_a
      end

      def size
        @pdf_paths.size
      end

      def include?(path)
        @pdf_paths.include?(path)
      end

      alias each_pair each
      alias keys pdf_paths
      alias has_key? include?
      alias [] info
    end
  end
end