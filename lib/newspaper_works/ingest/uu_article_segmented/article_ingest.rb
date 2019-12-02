module NewspaperWorks
  module Ingest
    module UUArticleSegmented
      class ArticleIngest
        # Mixin XML access:
        include NewspaperWorks::Ingest::UUArticleSegmented::IngestCommon
        # Mixin issue parent access:
        include NewspaperWorks::Ingest::UUArticleSegmented::HasIssueParent

        attr_accessor :path, :issue

        def initialize(path, issue = nil)
          @path = path
          @doc = nil
          @issue = issue
        end

        # Path to article image (PDF)
        # @return [String]
        def image_path
          File.expand_path(
            xpath('//article-clipping/@image-file').first.value,
            File.dirname(@path)
          )
        end

        # Article text as whitespace-delimited tokens for full-text indexing.
        #  THIS IS NOT HUMAN-READABLE, but intended as OCR-discovered text
        #  tokens in order, including alternates.
        def text
          tokens = xpath(
            './/article-element[@type="article"]//n'
          ).to_a.map { |n| n.text }
          line = tokens.join(' ')
          # word-wrap long line to 80 column lines for easier debug/viewing:
          line.scan(/\S.{0,#{80}}\S(?=\s|$)|\S+/).join("\n")
        end

        # get ordered list of pages, within issue
        # @return [Array<NewspaperWorks::Ingest::UUArticleSegmented::PageIngest]
        def pages
          # page appears to be singular, but treat as plural of size 1
          page_numbers = [xpath('//header-item[@name="page"]').first.text]
          page_numbers.map { |n| issue.get(n) }
        end
      end
    end
  end
end
