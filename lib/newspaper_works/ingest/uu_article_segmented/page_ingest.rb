module NewspaperWorks
  module Ingest
    module UUArticleSegmented
      class PageIngest
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

        # @return [String] Page number string, as provided by XML:
        def page_number
          xpath('//header-item[@name="page"]/@value').first.text
        end

        # Title, including publication title, date when available.
        # @return [String]
        def title
          return ["#{@issue.title.first}: Page #{page_number}"] unless @issue.nil?
          # fallback to just publication date and page number
          ["#{publication_date}: Page #{page_number}"]
        end     

        # Path to page image (PDF)
        # @return [String]
        def image_path
          File.expand_path(
            xpath('//page/@image-file').first.value,
            File.dirname(@path)
          )
        end

        # Page text as whitespace-delimited tokens for full-text indexing.
        #  THIS IS NOT HUMAN-READABLE, but intended as OCR-discovered text
        #  tokens in order, including alternates.
        def text
          tokens = xpath(
            './/nodes//n'
          ).to_a.map(&:text)
          line = tokens.join(' ')
          # word-wrap long line to 80 column lines for easier debug/viewing:
          line.scan(/\S.{0,#{80}}\S(?=\s|$)|\S+/).join("\n")
        end
      end
    end
  end
end
