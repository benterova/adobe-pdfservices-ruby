# frozen_string_literal: true

module PdfServices
  module DocumentMerge
    module Operation
      include Base::Operation
      OPERATION_ENDPOINT = 'https://pdf-services.adobe.io/operation/documentgeneration'

      def document_merge(_template_path = nil, json_data_for_merge = nil, output_format = nil)
        asset_id = upload_asset(@template_path)
        response = api.post(OPERATION_ENDPOINT, json: {
                              assetID: asset_id,
                              outputFormat: output_format,
                              jsonDataForMerge: json_data_for_merge
                            })
        if response.status == 201
          document_url = response.headers['location']
          poll_document_result(document_url, asset_id) do |response|
            handle_response(response)
          end
        else
          result_class.new(nil,
                           "Unexpected response status from document merge endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      private

      def handle_response(response)
        # download_the_asset
        download_uri = api.get(response['asset']['downloadUri'])
        result_class.new(download_uri.body, nil)
      end

      def result_class
        Result
      end
    end
  end
end
