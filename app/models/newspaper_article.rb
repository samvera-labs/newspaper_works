# Newspaper Article Cass
class NewspaperArticle < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata
  include NewspaperWorks::ScannedMediaMetadata

  self.indexer = NewspaperArticleIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperPage]

  # Validation and required fields:
  validates :title, presence: {
    message: 'A newspaper article requires a title.'
  }

  validates :publication_date, format: { with: DateRegex,
    message: "Incorrect Date. Date input should be formatted yyyy-mm-dd."},
    allow_nil: true, allow_blank: true

  validate :publication_date_valid

  def publication_date_valid
    error_msg = "Incorrect Date. Date input should be formatted yyyy-mm-dd and be a valid date."
    if publication_date.present?
      if !DateRegex.match(publication_date)
        errors.add(:publication_date, error_msg)
      else
        date_split = publication_date.split("-").map(&:to_i)
        if !Date.valid_date?(date_split[0], date_split[1], date_split[2])
          errors.add(:publication_date, error_msg)
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

  self.human_readable_type = 'Newspaper Article'

  # == Type-specific properties ==

  # TODO: DRY on the indexing of fields, the index block is repetitive...

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2

  # - Author
  property(
    :author,
    predicate: ::RDF::Vocab::MARCRelators.aut,
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Photographer
  property(
    :photographer,
    predicate: ::RDF::Vocab::MARCRelators.pht,
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Volume
  property(
    :volume,
    predicate: ::RDF::Vocab::BIBO.volume,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Edition
  property(
    :edition,
    predicate: ::RDF::Vocab::BIBO.edition,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Issue
  property(
    :issue,
    predicate: ::RDF::Vocab::BIBO.issue,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Geographic coverage
  property(
    :geographic_coverage,
    predicate: ::RDF::Vocab::DC.spatial,
    multiple: true
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


  # TODO: Add Reel number: https://github.com/samvera-labs/uri_selection_wg/issues/2

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods:

  def pages
    self.members.select { |v| v.instance_of?(NewspaperPage) }
  end

  def issue
    issues = self.member_of.select { |v| v.instance_of?(NewspaperIssue) }
    issues[0] unless !issues.length
  end

  def publication
    issue = self.issue
    issue.publication unless issue.nil?
  end

  def containers
    pages = self.pages
    if pages.length > 0
      return pages[0].member_of.select { |v| v.instance_of?(NewspaperContainer) }
    end
  end
end
