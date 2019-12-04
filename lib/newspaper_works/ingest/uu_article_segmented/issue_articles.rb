module NewspaperWorks
  module Ingest
    module UUArticleSegmented
      # Enumerable and ordered mapping of articles
      class IssueArticles
        # PathEnumeration mixes in #each for Enumerable, this class provides
        #   both #info and #paths methods to make PathEnumeration work.
        include NewspaperWorks::Ingest::PathEnumeration
        include Enumerable
        # XML and date accessors common functionality:
        include NewspaperWorks::Ingest::UUArticleSegmented::IngestCommon

        attr_accessor :path, :issue

        def initialize(path, issue = nil)
          @path = normalize_path(path)
          @doc = nil
          # reference to parent IssueIngest object, if available:
          @issue = issue
          # unordered cache of article objects, keyed by path
          @articles = {}
        end

        # get/enumerate articles, to meet contract of PathEnumeration mixin:

        # @return [Array<String>] list of article paths in manifest order
        def paths
          result = xpath('//articles/article-ref/@href').map(&:value)
          # normalize to absolute paths relative to location of manifest
          result.map { |p| File.expand_path(p, File.dirname(@path)) }
        end

        # @return [NewspaperWorks::Ingest::UUArticleSegmented::ArticleIngest]
        def info(path)
          return @articles[path] if @articles.keys.include?(path)
          @articles[path] = NewspaperWorks::Ingest::UUArticleSegmented::ArticleIngest.new(
            path, @issue
          )
        end

        # return path, or if path is directory, the path to a unit.xml file
        #   within it.
        # @param path [String]
        # @return [String] normalized path to issue unit.xml file.
        def normalize_path(path)
          return path unless File.directory?(path)
          path = File.expand_path('./unit.xml', path)
          raise IOError, 'Manifest not found: #{path}' unless File.exist?(path)
          path
        end
      end
    end
  end
end
