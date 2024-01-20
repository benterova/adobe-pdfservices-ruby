# frozen_string_literal: true

module PdfServices
  module HtmlToPdf
    module Operation
      include Base::Operation
      OPERATION_ENDPOINT = 'https://pdf-services.adobe.io/operation/htmltopdf'

      def html_to_pdf(zip_file_path = nil, json_data_for_merge = nil)
        asset_id = upload_asset(zip_file_path)
        response = api.post(OPERATION_ENDPOINT, json: {
                              assetID: asset_id,
                              json: json_data_for_merge&.to_json,
                              pageLayout: { pageWidth: 8.5, pageHeight: 11 },
                              includeHeaderFooter: false
                            })
        if response.status == 201
          document_url = response.headers['location']
          poll_document_result(document_url, asset_id) do |response|
            handle_response(response)
          end
        else
          result_class.new(nil,
                           "Unexpected response status from html to pdf endpoint: #{response.status}\nasset_id: #{asset_id}")
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
