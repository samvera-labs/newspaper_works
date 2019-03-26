# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    delegate :edition, :frequency, :preceded_by, :succeeded_by, to: :solr_document

    def issues
      all_title_issues.select { |issue| year_or_nil(issue["publication_date_dtsim"]) == year }
    end

    def issue_dates
      issues.pluck("publication_date_dtsim")
    end

    def issue_years
      all_title_issue_dates.map { |issue| year_or_nil(issue) }.compact.uniq.sort
    end

    def prev_year
      return nil if issue_years.empty?
      index = issue_years.index(year) - 1
      return nil if index.negative?
      issue_years[index]
    end

    def next_year
      return nil if issue_years.empty?
      issue_years[issue_years.index(year) + 1]
    end

    def publication_date_start
      solr_document["publication_date_start_dtsim"]
    end

    def publication_date_end
      solr_document["publication_date_end_dtsim"]
    end

    def year
      return nil if issue_years.empty?
      number_or_nil(request.params[:year]) || issue_years.first
    end

    def all_title_issues
      solr_document["member_ids_ssim"].map { |id| find_or_nil(id) }.compact
                                      .select { |doc| doc["has_model_ssim"] = "NewspaperIssue" }
    end

    private

      def all_title_issue_dates
        all_title_issues.pluck("publication_date_dtsim")
      end

      def find_or_nil(string)
        ::SolrDocument.find(string)
      rescue Blacklight::Exceptions::RecordNotFound
        nil
      end

      def number_or_nil(string)
        Integer(string || '')
      rescue ArgumentError
        nil
      end

      def year_or_nil(date_array)
        return nil unless date_array.array?
        Date.parse(date_array.first).year
      rescue TypeError
        nil
      end
  end
end
