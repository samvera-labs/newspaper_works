# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    delegate :edition, :frequency, :preceded_by, :succeeded_by, to: :solr_document

    def issues
      issue_list = []
      members.each do |member|
        issue_list << member if member.class == NewspaperIssue
      end
      issue_list
    end

    def publication_date_start
      solr_document["publication_date_start_dtsim"]
    end

    def publication_date_end
      solr_document["publication_date_end_dtsim"]
    end

    private

      def members
        NewspaperTitle.find(solr_document.id).members
      end
  end
end
