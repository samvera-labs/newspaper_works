require 'uri'

module NewspaperWorks
  module Data
    # Mixin for methods related to paths on filesystem
    module PathHelper
      def normalize_path(path)
        path = path.to_s
        isuri?(path) ? path : File.expand_path(path)
      end

      def isuri?(path)
        !path.scan(URI.regexp).empty?
      end

      def path_to_uri(path)
        isuri?(path) ? path : "file://#{path}"
      end

      def whitelisted_path(path)
        Hyrax.config.whitelisted_ingest_dirs.any? do |dir|
          path.start_with?(dir) && path.length > dir.length
        end
      end

      def validate_path(path)
        # treat file URIs equivalent to local paths
        path = File.expand_path(path.sub(/^file:\/\//, ''))
        # make sure file exists
        raise IOError, "Not found: #{path}" unless File.exist?(path)
        return if whitelisted_path(path)
        # we cannot use path if it is not whitelisted for Hyrax ingest, we
        #   would prefer to fail early vs. later+silently
        raise SecurityError,
          "Path specified is not configured in Hyrax ingest whitelist: " \
          "#{path}"
      end
    end
  end
end
