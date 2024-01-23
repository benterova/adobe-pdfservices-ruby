# frozen_string_literal: true

module PdfServices
  module HtmlToPdf
    class Operation < Base::Operation
      OPERATION_ENDPOINT = 'https://pdf-services.adobe.io/operation/htmltopdf'

      def initialize(api, zip_file_path)
        super(api)
        @zip_file_path = zip_file_path
      end

      def execute(json_data_for_merge)
        asset_id = upload_asset(@zip_file_path)
        response = @api.post(OPERATION_ENDPOINT, json: {
                               assetID: asset_id,
                               json: json_data_for_merge&.to_json,
                               pageLayout: { pageWidth: 8.5, pageHeight: 11 },
                               includeHeaderFooter: false
                             })

        handle_html_to_pdf_response(response, asset_id)
      end

      private

      def handle_html_to_pdf_response(response, asset_id)
        if response.status == 201
          document_url = response.headers['location']
          poll_document_result(document_url, asset_id) do |response|
            handle_pdf_response(response)
          end
        else
          Result.new(nil,
                     "Unexpected response status from html to pdf endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      def handle_pdf_response(response)
        download_uri = @api.get(response['asset']['downloadUri'])
        Result.new(download_uri.body, nil)
      end
    end
  end
end
