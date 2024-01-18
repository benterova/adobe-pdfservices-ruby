# frozen_string_literal: true

require "pdfservices/ocr/result"
require "pdfservices/base/operation"

module PdfServices
  module Ocr
    class Operation < PdfServices::Base::Operation
      OCR_ENDPOINT = "https://pdf-services.adobe.io/operation/ocr"

      def initialize(credentials = nil)
        super(credentials)
      end

      def execute(source_pdf)
        asset_id = upload_asset(source_pdf)
        response = api.post(OCR_ENDPOINT, json: {assetID: asset_id})
        if response.status == 201
          document_url = response.headers["location"]
          poll_document_result(document_url, asset_id) do |response|
            handle_response(response)
          end
        else
          result_class.new(nil, "Unexpected response status from ocr endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      private

      def handle_response(response)
        # download_the_asset
        download_uri = HTTP.get(response["asset"]["downloadUri"])
        # return the result
        result_class.new(download_uri.body, nil)
      end

      def result_class
        Result
      end
    end
  end
end
