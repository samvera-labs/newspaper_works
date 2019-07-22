# NewspaperIssue ancestor data
module NewspaperWorks
  # shared NewspaperIssue info for multiple newspaper models
  module IssueInfoPresenter
    delegate :publication_date, to: :solr_document

    def issue_id
      solr_document['issue_id_ssi']
    end

    def issue_title
      solr_document['issue_title_ssi']
    end

=begin
TESTING
    def publication_date
      solr_document.publication_date
    end
=end

    def issue_volume
      solr_document['issue_volume_ssi']
    end

    def issue_edition
      solr_document['issue_edition_number_ssi']
    end

    def issue_number
      solr_document['issue_number_ssi']
    end
  end
end
