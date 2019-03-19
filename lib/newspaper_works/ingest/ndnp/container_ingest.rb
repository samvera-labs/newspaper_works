module NewspaperWorks
  module Ingest
    module NDNP
      class ContainerIngest
        # Enumerable of PageIngest objects for pages on reel
        include Enumerable
        include NewspaperWorks::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :doc, :dmdids

        def initialize(path)
          @path = path
          @doc = nil
          @metadata = nil
          # Enumeration based on list of DMDID loaded by load_doc
          @dmdids = nil
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
          metadata.reel_number
        end

        def page_by_dmdid(dmdid)
          NewspaperWorks::Ingest::NDNP::PageIngest.new(@path, dmdid, self)
        end

        def each
          @dmdids.each do |dmdid|
            yield page_by_dmdid(dmdid)
          end
        end

        def size
          @dmdids.size
        end

        def metadata
          return @metadata unless @metadata.nil?
          @metadata = NewspaperWorks::Ingest::NDNP::ContainerMetadata.new(
            path,
            self
          )
        end

        private

          def load_doc
            @doc = Nokogiri::XML(File.open(path)) if @doc.nil?
            page_divs = doc.xpath(
              "//mets:structMap/mets:div[@TYPE='np:reel']/" \
                "mets:div[@TYPE='np:target']",
              mets: 'http://www.loc.gov/METS/'
            )
            @dmdids = page_divs.map { |div| div.attr('DMDID') }
          end
      end
    end
  end
end
