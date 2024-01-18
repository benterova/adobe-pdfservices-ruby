# frozen_string_literal: true

require "pdfservices/html_to_pdf/result"
require "pdfservices/base/operation"

module PdfServices
  module HtmlToPdf
    class Operation < Base::Operation
      OPERATION_ENDPOINT = "https://pdf-services.adobe.io/operation/htmltopdf"

      def initialize(credentials = nil, zip_file_path = nil, json_data_for_merge = nil)
        super(credentials)
        @zip_file_path = zip_file_path
        @json_data_for_merge = json_data_for_merge
      end

      def execute
        asset_id = upload_asset(@zip_file_path)
        response = api.post(OPERATION_ENDPOINT, json: {
          assetID: asset_id,
          json: @json_data_for_merge&.to_json,
          pageLayout: {pageWidth: 8.5, pageHeight: 11},
          includeHeaderFooter: false
        })
        if response.status == 201
          document_url = response.headers["location"]
          poll_document_result(document_url, asset_id) do |response|
            handle_response(response)
          end
        else
          result_class.new(nil, "Unexpected response status from html to pdf endpoint: #{response.status}\nasset_id: #{asset_id}")
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
