# frozen_string_literal: true

require "pdfservices/base/operation"
require "pdfservices/document_merge/result"

module PdfServices
  module DocumentMerge
    class Operation < Base::Operation
      OPERATION_ENDPOINT = "https://pdf-services.adobe.io/operation/documentgeneration"

      def initialize(credentials = nil, template_path = nil, json_data_for_merge = nil, output_format = nil)
        super(credentials)
        @template_path = template_path
        @json_data_for_merge = json_data_for_merge
        @output_format = output_format
      end

      def execute
        asset_id = upload_asset(@template_path)
        response = api.post(OPERATION_ENDPOINT, json: {
          assetID: asset_id,
          outputFormat: @output_format,
          jsonDataForMerge: @json_data_for_merge
        })
        if response.status == 201
          document_url = response.headers["location"]
          poll_document_result(document_url, asset_id) do |response|
            handle_response(response)
          end
        else
          result_class.new(nil, "Unexpected response status from document merge endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      private

      def handle_response(response)
        # download_the_asset
        download_uri = HTTP.get(response["asset"]["downloadUri"])
        result_class.new(download_uri.body, nil)
      end

      def result_class
        Result
      end
    end
  end
end
