require "pdfservices/extract_pdf/result"

module PdfServices
  module ExtractPdf
    class Operation < Base::Operation
      OPERATION_ENDPOINT = "https://pdf-services.adobe.io/operation/extractpdf"
      VALID_ELEMENTS = %w[tables text].freeze
      TABLE_OUTPUT_FORMATS = %w[csv xlsx].freeze
      RENDITIONS_EXTRACTS = %w[tables figures].freeze

      def initialize(credentials = nil, source_pdf = nil)
        super(credentials)
        @source_pdf = source_pdf
      end

      # See https://developer.adobe.com/document-services/docs/apis/#tag/Extract-PDF/operation/pdfoperations.extractpdf

      def execute(renditions_to_extract:, table_output_format:, include_styling: false, extract_elements: VALID_ELEMENTS, get_char_bounds: false)
        raise ArgumentError, "Invalid extract_elements: #{extract_elements - VALID_ELEMENTS}" unless (extract_elements - VALID_ELEMENTS).empty?

        asset_id = upload_asset(@source_pdf)
        response = api.post(OPERATION_ENDPOINT, json: {
          assetID: asset_id,
          includeStyling: include_styling,
          getCharBounds: get_char_bounds,
          renditions: renditions_to_extract,
          tableOutputFormat: table_output_format,
          extractElements: extract_elements
        })

        if response.status == 201
          document_url = response.headers["location"]
          poll_document_result(document_url, asset_id) do |response|
            handle_response(response)
          end
        else
          result_class.new(nil, "Unexpected response status from extract pdf endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      private

      def handle_response(response)
        download_uri = HTTP.get(response["content"]["downloadUri"])
        result_class.new(download_uri.body, nil)
      end

      def result_class
        Result
      end
    end
  end
end
