module NewspaperWorks
  module Ingest
    module UUArticleSegmented
      # IssueIngest is enumerable of pages, and has accessor to list
      #   contained articles; it is constructed with a path.
      class IssueIngest
        # PathEnumeration mixes in #each for Enumerable, this class provides
        #   both #info and #paths methods to make PathEnumeration work.
        include NewspaperWorks::Ingest::PathEnumeration
        include Enumerable
        # XML and date accessors common functionality:
        include NewspaperWorks::Ingest::UUArticleSegmented::IngestCommon

        attr_accessor :path, :issue

        def initialize(path)
          @path = normalize_path(path)
          @doc = nil
          @issue = nil
          @pages = {}
          @articles = nil
        end

        # enumerable stuff: get/enumerate pages of issue
        def info(path)
          return @pages[path] if @pages.keys.include?(path)
          # construct each page in context of (this) issue parent:
          @pages[path] = page_for_path(path)
        end

        def page_for_path(path)
          NewspaperWorks::Ingest::UUArticleSegmented::PageIngest.new(
            path, self
          )
        end

        # @return [Array<String>] list of paths to each page in manifest order
        def paths
          result = xpath('//pages/page-ref/@href').map(&:value)
          # normalize to absolute paths relative to location of manifest
          result.map { |p| File.expand_path(p, File.dirname(@path)) }
        end

        def article_paths
          result = xpath('//articles/article-ref/@href').map(&:value)
          # normalize to absolute paths relative to location of manifest
          result.map { |p| File.expand_path(p, File.dirname(@path)) }
        end

        def article(path)
          NewspaperWorks::Ingest::UUArticleSegmented::ArticleIngest.new(
            path, self
          )
        end

        # @return [Hash{String, NewspaperWorks::Ingest::UUArticleSegmented::ArticleIngest}]
        #   list of articles for issue, linked back to this issue
        def articles
          return @articles unless @articles.nil?
          @articles = article_paths.map { |path| [path, article(path)] }.to_h
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
