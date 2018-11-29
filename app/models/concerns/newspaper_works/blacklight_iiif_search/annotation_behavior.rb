# customize behavior for IiifSearch
module NewspaperWorks
  module BlacklightIiifSearch
    module AnnotationBehavior
      ##
      # Create a URL for the annotation
      # use a Hyrax-y URL syntax:
      # protocol://host:port/concern/model_type/work_id/manifest/canvas/file_set_id/annotation/index
      # @return [String]
      def annotation_id
        "#{base_url}/manifest/canvas/#{file_set_id}/annotation/#{hl_index}"
      end

      ##
      # Create a URL for the canvas that the annotation refers to
      # match the Hyrax default canvas URL syntax:
      # protocol://host:port/concern/model_type/work_id/manifest/canvas/file_set_id
      # @return [String]
      def canvas_uri_for_annotation
        "#{base_url}/manifest/canvas/#{file_set_id}#{coordinates}"
      end

      private

        ##
        # return a string like "#xywh=100,100,250,20"
        # corresponding to coordinates of query term on image
        # local implementation expected, value returned below is just a placeholder
        # @return [String]
        def coordinates
          return '' unless query
          coords_file = NewspaperWorks::Data::WorkDerivativeLoader.new(file_set_id).data('json')
          return '' unless coords_file
          coords_json = JSON.parse(coords_file)
          return '#xywh=0,0,0,0' unless coords_json['words']
          matches = coords_json['words'].select do |k, _v|
            k['word'].downcase =~ /#{query.downcase}/
          end
          coords_array = matches[hl_index]['coordinates']
          "#xywh=#{coords_array.join(',')}"
        end

        def base_url
          host = controller.request.base_url
          Rails.application.routes.url_helpers.polymorphic_url(parent_document,
                                                               host: host)
        end

        def file_set_id
          file_set_ids = document['file_set_ids_ssim']
          raise "#{name}: NO FILE SET ID" if file_set_ids.blank?
          file_set_ids.first
        end
    end
  end
end
