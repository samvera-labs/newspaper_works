module NewspaperWorks
  module Ingest
    class BasePublicationInfo
      attr_accessor :lccn, :issn

      def initialize(lccn)
        @lccn = lccn
        # some authorities may not have issn, so have a default nil value:
        @issn = nil
        load
      end

      def load
        raise NotImplementedError, "abstract"
      end

      def place_name_from_title(title)
        title.split(/ [\(]/)[1].split(')')[0]
      end
    end
  end
end
