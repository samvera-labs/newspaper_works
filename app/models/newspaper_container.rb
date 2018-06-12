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

  validate :publication_date_start_valid,
           :publication_date_end_valid,
           :publication_date_start_before_publication_date_end

  @date_incorrect_error_msg = "Incorrect Date. Date input should be formatted yyyy[-mm][-dd] and be a valid date."
  def publication_date_start_valid
    return if !publication_date_start.present? || publication_date_valid?(publication_date_start)
    errors.add(:publication_date_start, @date_incorrect_error_msg)
  end

  def publication_date_end_valid
    return if !publication_date_end.present? || publication_date_valid?(publication_date_end)
    errors.add(:publication_date_end, @date_incorrect_error_msg)
  end

  def publication_date_start_before_publication_date_end
    return unless publication_date_start.present? && publication_date_end.present?
    pub_start = publication_date_start.split("-")
    pub_end = publication_date_end.split("-")
    (0..2).each do |i|
      errors.add(:publication_date_start, "Publication start date must be earlier or the same as end date.") if pub_start[i] && pub_end[i] && pub_end[i] < pub_start[i]
      break
    end
  end

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
    result = member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.empty?
  end

  def pages
    members.select { |v| v.instance_of?(NewspaperPage) }
  end

  private

    def publication_date_valid?(pub_date)
      return false unless DATE_RANGE_REGEX.match(pub_date)
      date_split = pub_date.split("-").map(&:to_i)
      return false if date_split.length == 3 &&
                      !Date.valid_date?(date_split[0], date_split[1], date_split[2])
      true
    end
end
