# frozen_string_literal: true

require "http"
require "pdfservices/jwt_provider"
require "pdfservices/ocr/result"
require "pdfservices/base/operation"
require "yaml"

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
          poll_document_result(document_url, asset_id)
        else
          Result.new(nil, "Unexpected response status from ocr endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      private

      def result_class
        Result
      end
    end
  end
end
