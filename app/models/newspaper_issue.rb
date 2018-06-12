# Newspaper Issue
class NewspaperIssue < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperIssueIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  # Validation and required fields:
  validates :title, presence: {
    message: 'Your work must have a title.'
  }

  validate :publication_date_valid

  def publication_date_valid
    error_msg = "Incorrect Date. Date input should be formatted yyyy-mm-dd and be a valid date."
    return unless publication_date.present?
    unless DATE_REGEX.match(publication_date)
      errors.add(:publication_date, error_msg)
      return
    end
    date_split = publication_date.split("-").map(&:to_i)
    errors.add(:publication_date, error_msg) unless Date.valid_date?(date_split[0], date_split[1], date_split[2])
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

  self.human_readable_type = 'Newspaper Issue'

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2

  #  - Volume
  property(
    :volume,
    predicate: ::RDF::Vocab::BIBO.volume,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  #  - Edition
  property(
    :edition,
    predicate: ::RDF::Vocab::BIBO.edition,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  #  - Issue
  property(
    :issue,
    predicate: ::RDF::Vocab::BIBO.issue,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Extent
  property(
    :extent,
    predicate: ::RDF::Vocab::DC.extent,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  #  - publication date
  property(
    :publication_date,
    predicate: ::RDF::Vocab::DC.issued,
    multiple: false
  ) do |index|
    index.as :dateable
  end

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods
  def publication
    result = member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.empty?
  end

  def articles
    members.select { |v| v.instance_of?(NewspaperArticle) }
  end

  def pages
    members.select { |v| v.instance_of?(NewspaperPage) }
  end
end
