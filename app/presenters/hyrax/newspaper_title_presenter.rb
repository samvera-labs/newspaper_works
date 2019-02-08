# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    delegate :edition, :frequency, :preceded_by, :succeeded_by, to: :solr_document

    def issues
      all_title_issues.select { |issue| Date.parse(issue.publication_date).year == year }
    end

    def issue_dates
      issues.pluck(:publication_date)
    end

    def issue_years
      all_title_issue_dates.map { |issue| Date.parse(issue).year }.uniq.sort
    end

    def prev_year
      index = issue_years.index(year) - 1
      return nil if index < 0
      issue_years[index]
    end

    def next_year
      issue_years[issue_years.index(year) + 1]
    end

    def publication_date_start
      solr_document["publication_date_start_dtsim"]
    end

    def publication_date_end
      solr_document["publication_date_end_dtsim"]
    end

    def year
      number_or_nil(request.params[:year]) || issue_years.first
    end

    private

      def all_title_issues
        members = NewspaperTitle.find(solr_document.id).members
        members.select { |member| member.class == NewspaperIssue }
      end

      def all_title_issue_dates
        all_title_issues.pluck(:publication_date)
      end

      def number_or_nil(string)
        Integer(string || '')
      rescue ArgumentError
        nil
      end
  end
end
