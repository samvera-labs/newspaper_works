# module comment...
module NewspaperWorks
  # core metadata for newspaper models
  module NewspaperCoreMetadata
    extend ActiveSupport::Concern

    included do
      # common metadata for Newspaper title, issue, article; fields
      # that are not in ::Hyrax::BasicMetadata are enumerated here.

      # - Alternative Title
      property(
        :alternative_title,
        predicate: ::RDF::Vocab::DC.alternative,
        multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      # - Genre
      property(
        :genre,
        predicate: ::RDF::Vocab::EDM.hasType,
        multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      #  - Place of Publication
      property(
        :place_of_publication,
        predicate: ::RDF::Vocab::MARCRelators.pup,
        multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      #  - Place of Publication (State)
      property(
        :place_of_publication_state,
        predicate: ::RDF::Vocab::SCHEMA.State,
        multiple: true
      ) do |index|
        index.as :symbol
      end

      #  - Place of Publication (City)
      property(
        :place_of_publication_city,
        predicate: ::RDF::Vocab::SCHEMA.City,
        multiple: true
      ) do |index|
        index.as :symbol
      end

      #  - Place of Publication (Latitude)
      property(
        :place_of_publication_latitude,
        predicate: ::RDF::Vocab::SCHEMA.latitude,
        multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      #  - Place of Publication (Longitude)
      property(
        :place_of_publication_longitude,
        predicate: ::RDF::Vocab::SCHEMA.longitude,
        multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      # - ISSN
      property(
        :issn,
        predicate: ::RDF::Vocab::Identifiers.issn,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - LCCN
      property(
        :lccn,
        predicate: ::RDF::Vocab::Identifiers.lccn,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - OCLC Number
      property(
        :oclcnum,
        predicate: ::RDF::Vocab::BIBO.oclcnum,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # Holding location (held by):
      property(
        :held_by,
        predicate: ::RDF::Vocab::BF2.heldBy,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      class_attribute :controlled_properties
      self.controlled_properties = []
    end
  end
end
