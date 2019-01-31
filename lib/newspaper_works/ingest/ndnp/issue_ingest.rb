module NewspaperWorks
  module Ingest
    module NDNP
      class IssueIngest
        include Enumerable
        include NewspaperWorks::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :doc

        def initialize(path)
          @path = path
          @doc = nil
          @metadata = nil
          load_doc
        end

        def inspect
          format(
            "<#{self.class}:0x000000000%<oid>x\n" \
              "\tpath: '#{path}',\n",
            oid: object_id << 1
          )
        end

        def identifier
          metadata.lccn
        end

        def page_by_dmdid(dmdid)
        end

        def page_by_sequence_number(n)
        end

        def each(&block)
        end

        def size
        end

        def metadata
          return @metadata unless @metadata.nil?
          @metadata = NewspaperWorks::Ingest::NDNP::IssueMetadata.new(path)
        end

        private

          def load_doc
            @doc = Nokogiri::XML(File.open(path)) if @doc.nil?
          end
      end
    end
  end
end
