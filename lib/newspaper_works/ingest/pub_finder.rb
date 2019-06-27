require 'newspaper_works/logging'
require 'newspaper_works/ingest'

module NewspaperWorks
  module Ingest
    # mixin for find-or-create of publication, for use by various ingests
    module PubFinder
      include NewspaperWorks::Logging

      # @param lccn [String] Library of Congress Control Number
      #   of Publication
      # @return [NewspaperTitle, NilClass] publication or nil if not found
      def find_publication(lccn)
        NewspaperTitle.where(lccn: lccn).first
      end

      def copy_publication_title(publication, title)
        parts = title.split(/ [\(]/)
        publication.title = [parts[0]]
        return unless parts.size > 1
        place_name = parts[1].split(')')[0]
        uri = NewspaperWorks::Ingest.geonames_place_uri(place_name)
        publication.place_of_publication = [uri] unless uri.nil?
      end

      def create_publication(lccn, title = nil, opts = {})
        publication = NewspaperTitle.create
        copy_publication_title(publication, title || lccn)
        publication.lccn ||= lccn
        NewspaperWorks::Ingest.assign_administrative_metadata(publication, opts)
        publication.save!
        write_log(
          "Created NewspaperTitle work #{publication.id} for LCCN #{lccn}"
        )
        publication
      end

      def find_or_create_publication_for_issue(issue, lccn, title, opts)
        publication = find_publication(lccn)
        unless publication.nil?
          write_log(
            "Found existing NewspaperTitle #{publication.id}, LCCN #{lccn}"
          )
        end
        publication = create_publication(lccn, title, opts) if publication.nil?
        publication.ordered_members << issue
        publication.save!
        write_log(
          "Linked NewspaperIssue #{issue.id} to "\
          "NewspaperTitle work #{publication.id}"
        )
      end
    end
  end
end
