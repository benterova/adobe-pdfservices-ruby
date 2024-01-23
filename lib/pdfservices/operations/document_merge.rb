# frozen_string_literal: true

module PdfServices
  module DocumentMerge
    class Operation < Base::Operation
      OPERATION_ENDPOINT = 'https://pdf-services.adobe.io/operation/documentgeneration'

      def initialize(api, template_path)
        super(api)
        @template_path = template_path
      end

      def execute(json_data_for_merge, output_format = 'pdf')
        asset_id = upload_asset(@template_path)
        response = @api.post(OPERATION_ENDPOINT, json: {
                               assetID: asset_id,
                               outputFormat: output_format,
                               jsonDataForMerge: json_data_for_merge
                             })

        handle_document_merge_response(response, asset_id)
      end

      private

      def handle_document_merge_response(response, asset_id)
        if response.status == 201
          document_url = response.headers['location']
          poll_document_result(document_url, asset_id) do |response|
            handle_merge_response(response)
          end
        else
          Result.new(nil,
                     "Unexpected response status from document merge endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      def handle_merge_response(response)
        download_uri = @api.get(response['asset']['downloadUri'])
        Result.new(download_uri.body, nil)
      end
    end
  end
end
