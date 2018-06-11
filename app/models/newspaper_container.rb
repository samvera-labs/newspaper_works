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

  def publication_date_start_valid
    error_msg = "Incorrect Date. Date input should be formatted yyyy[-mm][-dd] and be a valid date."
    if publication_date_start.present?
      if !DateRangeRegex.match(publication_date_start)
        errors.add(:publication_date_start, error_msg)
      else
        date_split = publication_date_start.split("-").map(&:to_i)
        if date_split.length == 3
          if !Date.valid_date?(date_split[0], date_split[1], date_split[2])
            errors.add(:publication_date_start, error_msg)
          end
        end
      end
    end
  end

  def publication_date_end_valid
    error_msg = "Incorrect Date. Date input should be formatted yyyy[-mm][-dd] and be a valid date."
    if publication_date_end.present?
      if !DateRangeRegex.match(publication_date_end)
        errors.add(:publication_date_end, error_msg)
      else
        date_split = publication_date_end.split("-").map(&:to_i)
        if date_split.length == 3
          if !Date.valid_date?(date_split[0], date_split[1], date_split[2])
            errors.add(:publication_date_end, error_msg)
          end
        end
      end
    end
  end

  def publication_date_start_before_publication_date_end
    error_msg = "Publication start date must be earlier or the same as end date."
    if publication_date_start.present? && publication_date_end.present?
      pub_start = publication_date_start.split("-")
      pub_end = publication_date_end.split("-")
      if (pub_end[0] < pub_start[0])
        errors.add(:publication_date_start, error_msg)
      elsif (pub_start[1] && pub_end[1] && pub_end[1] < pub_start[1])
        errors.add(:publication_date_start, error_msg)
      elsif (pub_start[2] && pub_end[2] && pub_end[2] < pub_start[2])
        errors.add(:publication_date_start, error_msg)
      end
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
    result = self.member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.length == 0
  end

  def pages
    self.members.select { |v| v.instance_of?(NewspaperPage) }
  end
end
