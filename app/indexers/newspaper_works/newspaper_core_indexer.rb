# Core indexer for newspaper work types
module NewspaperWorks
  class NewspaperCoreIndexer < Hyrax::WorkIndexer
    # This indexes the default metadata. You can remove it if you want to
    # provide your own metadata and indexing.
    include Hyrax::IndexesBasicMetadata

    # Fetch remote labels for based_near. You can remove this if you don't want
    # this behavior
    # include Hyrax::IndexesLinkedMetadata

    # Uncomment this block if you want to add custom indexing behavior:
    # def generate_solr_document
    #  super.tap do |solr_doc|
    #    solr_doc['my_custom_field_ssim'] = object.my_custom_property
    #  end
    # end

    def generate_solr_document
      super.tap do |solr_doc|
        if defined? object.place_of_publication
          geodata = get_geodata(object.place_of_publication.first)
          if geodata && geodata.key?("name")
            solr_doc['place_of_publication_city_ssim'] = geodata["name"]
            solr_doc['place_of_publication_tesim'] = geodata["name"]
          end
          if geodata && geodata.key?("adminName1")
            solr_doc['place_of_publication_state_ssim'] = geodata["adminName1"]
            if solr_doc.key?("place_of_publication_tesim")
              solr_doc['place_of_publication_tesim'] << ", #{geodata['adminName1']}"
            else
              solr_doc['place_of_publication_tesim'] = geodata["adminName1"]
            end
          end
          if geodata && geodata.key?("countryName")
            solr_doc['place_of_publication_country_ssim'] = geodata["countryName"]
            if solr_doc.key?("place_of_publication_tesim")
              solr_doc['place_of_publication_tesim'] << ", #{geodata['countryName']}"
            else
              solr_doc['place_of_publication_tesim'] = geodata["countryName"]
            end
          end
          if geodata && geodata.key?("lat") && geodata.key?("lng")
            solr_doc['place_of_publication_llsim'] = "#{geodata['lat']}, "\
                                                     "#{geodata['lng']}"
          end
        end
        if defined? object.publication_date_start
          case object.publication_date_start
          when /\A\d{4}\z/
            solr_doc['publication_date_start_dtsim'] = "#{object.publication_date_start}-01-01T00:00:00Z"
          when /\A\d{4}-\d{2}\z/
            solr_doc['publication_date_start_dtsim'] = "#{object.publication_date_start}-01T00:00:00Z"
          end
        end
        if defined? object.publication_date_end
          case object.publication_date_end
          when /\A\d{4}\z/
            solr_doc['publication_date_end_dtsim'] = "#{object.publication_date_end}-12-31T23:59:59Z"
          when /\A\d{4}-\d{2}\z/
            date_split = object.publication_date_end.split('-')
            end_day = Date.new(date_split[0].to_i, date_split[1].to_i, -1).strftime("%d")
            solr_doc['publication_date_end_dtsim'] = "#{object.publication_date_end}-#{end_day}T23:59:59Z"
          end
        end
      end
    end

    private

      def get_geodata(geoname_id)
        return false if geoname_id.to_i.zero?
        geoname_user = config.geonames_username || "hive"
        geoname_url = "http://api.geonames.org/get?geonameId=#{geoname_id}&username=#{geoname_user}"
        resp = Net::HTTP.get_response(URI.parse(geoname_url))
        geodata = Hash.from_xml(resp.body)
        return geodata["geoname"] if geodata.key?("geoname")
        false
      end
  end
end
