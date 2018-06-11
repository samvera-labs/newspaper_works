# NewspaperTitle: object for a publication/title
class NewspaperTitle < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperTitleIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperContainer, NewspaperIssue]

  # Validation and required fields:
  validates :title, presence: {
    message: 'A newspaper title a title (publication name).'
  }

  validate :publication_date_start_valid, :publication_date_end_valid

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

  # validations below causing save failures
  # TODO: get them working || enforce validation elsewhere || remove

  # validates :type, presence: {
  #   message: 'A newspaper title requires a type.'
  # }

  # validates :genre, presence: {
  #   message: 'A newspaper title requires a genre.'
  # }

  self.human_readable_type = 'Newspaper Title'

  # == Type-specific properties ==

  # - Edition
  property(
    :edition,
    predicate: ::RDF::Vocab::BIBO.edition,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Frequency
  property(
    :frequency,
    predicate: ::RDF::URI.new('http://www.rdaregistry.info/Elements/u/P60538'),
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Preceded by
  property(
    :preceded_by,
    predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/u/P60261'),
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Succeeded by
  property(
    :succeeded_by,
    predicate: ::RDF::URI.new('http://rdaregistry.info/Elements/u/P60278'),
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Publication date start
  property(
    :publication_date_start,
    predicate: ::RDF::Vocab::SCHEMA.startDate,
    multiple: false
  ) do |index|
    index.as :dateable
  end

  # - Publication date end
  property(
    :publication_date_end,
    predicate: ::RDF::Vocab::SCHEMA.endDate,
    multiple: false
  ) do |index|
    index.as :dateable
  end

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods:
  def issues
    self.members.select { |v| v.instance_of?(NewspaperIssue) }
  end

  def containers
    self.members.select { |v| v.instance_of?(NewspaperContainer) }
  end

end
