# Newspaper Container
class NewspaperContainer < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperContainerIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperPage]

  # Validation and required fields:
  validates :title, presence: {
    message: 'A newspaper container requires a title.'
  }

  validates :publication_date_start, format: { with: DateRegex,
    message: "Incorrect Date. Date input should be formatted yyyy-mm-dd."},
    allow_nil: true, allow_blank: true

  validates :publication_date_end, format: { with: DateRegex,
    message: "Incorrect Date. Date input should be formatted yyyy-mm-dd."},
    allow_nil: true, allow_blank: true

  # TODO: Implement validations
  # validates :resource_type, presence: {
  #   message: 'A newspaper article requires a resource type.'
  # }
  # validates :genre, presence: {
  #   message: 'A newspaper article requires a genre.'
  # }
  # validates :language, presence: {
  #   message: 'A newspaper article requires a language.'
  # }
  # validates :held_by, presence: {
  #   message: 'A newspaper article requires a holding location.'
  # }

  self.human_readable_type = 'Newspaper Container'

  # == Type-specific properties ==

  # TODO: DRY on the indexing of fields, the index block is repetative...

  #  - Type (TODO: make a behavior mixin for common fields)

  # - Extent
  property(
    :extent,
    predicate: ::RDF::Vocab::DC.extent,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  #  - publication date start
  property(
    :publication_date_start,
    predicate: ::RDF::Vocab::SCHEMA.startDate,
    multiple: false
  ) do |index|
    index.as :dateable
  end

  #  - publication date end
  property(
    :publication_date_end,
    predicate: ::RDF::Vocab::SCHEMA.endDate,
    multiple: false
  ) do |index|
    index.as :dateable
  end

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2
  # TODO: Titles on reel

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods

  def publication
    result = self.member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.length == 0
  end

  def pages
    self.members.select { |v| v.instance_of?(NewspaperPage) }
  end
end
