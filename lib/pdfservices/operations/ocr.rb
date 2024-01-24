# frozen_string_literal: true

module PdfServices
  module Ocr
    class Operation < Base::Operation
      OCR_ENDPOINT = 'https://pdf-services-ue1.adobe.io/operation/ocr'

      def execute(source_pdf)
        asset_id = upload_asset(source_pdf)
        response = @api.post(OCR_ENDPOINT, json: { assetID: asset_id })

        if response.status == 201
          document_url = response.headers['location']
          poll_document_result(document_url, asset_id) do |response|
            handle_ocr_response(response)
          end
        else
          Result.new(nil, "Unexpected response status from OCR endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      private

      def handle_ocr_response(response)
        download_uri = @api.get(response['asset']['downloadUri'])
        Result.new(download_uri.body, nil)
      end
    end
  end
end
