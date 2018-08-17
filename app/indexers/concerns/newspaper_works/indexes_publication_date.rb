# indexes the publication_date_start and _end fields
module NewspaperWorks
  module IndexesPublicationDate
    # adds publication date start to solr_doc Hash in Solr datetime format
    #
    # @param pubdate [String] publication start date
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_pubdate_start(pubdate, solr_doc)
      case pubdate
      when /\A\d{4}\z/
        solr_doc['publication_date_start_dtsim'] = "#{pubdate}-01-01T00:00:00Z"
      when /\A\d{4}-\d{2}\z/
        solr_doc['publication_date_start_dtsim'] = "#{pubdate}-01T00:00:00Z"
      end
    end

    # adds publication date end to solr_doc Hash in Solr datetime format
    #
    # @param pubdate [String] publication end date
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_pubdate_end(pubdate, solr_doc)
      case pubdate
      when /\A\d{4}\z/
        solr_doc['publication_date_end_dtsim'] = "#{pubdate}-12-31T23:59:59Z"
      when /\A\d{4}-\d{2}\z/
        date_split = pubdate.split('-')
        end_day = Date.new(date_split[0].to_i, date_split[1].to_i, -1).strftime('%d')
        solr_doc['publication_date_end_dtsim'] = "#{pubdate}-#{end_day}T23:59:59Z"
      end
    end
  end
end
