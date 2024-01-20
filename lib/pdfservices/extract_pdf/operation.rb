module PdfServices
  module ExtractPdf
    module Operation
      include Base::Operation
      OPERATION_ENDPOINT = 'https://pdf-services.adobe.io/operation/extractpdf'.freeze
      VALID_EXTRACT_EXTRACT_ELEMENTS = %w[tables text].freeze
      TABLE_OUTPUT_FORMATS = %w[csv xlsx].freeze
      RENDITIONS_EXTRACTS = %w[tables figures].freeze

      # See https://developer.adobe.com/document-services/docs/apis/#tag/Extract-PDF/operation/pdfoperations.extractpdf

      def extract_pdf(source_pdf = nil, options = {})
        validate_options(options)

        include_styling = options[:include_styling] || false
        get_char_bounds = options[:get_char_bounds] || false

        asset_id = upload_asset(source_pdf)
        response = api.post(OPERATION_ENDPOINT, body: {
                              assetID: asset_id,
                              includeStyling: include_styling,
                              getCharBounds: get_char_bounds,
                              renditions: options[:renditions_to_extract],
                              tableOutputFormat: options[:table_output_format],
                              extractElements: options[:extract_elements]
                            })

        handle_extract_pdf_response(response, asset_id)
      end

      private

      def handle_extract_pdf_response(response, asset_id)
        if response.code == 201
          document_url = response.headers['location']
          poll_document_result(document_url, asset_id) do |response|
            handle_response(response)
          end
        else
          result_class.new(nil,
                           "Unexpected response status from extract pdf endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      def validate_options(options)
        renditions_to_extract = options[:renditions_to_extract] || []
        table_output_format = options[:table_output_format] || TABLE_OUTPUT_FORMATS.first
        extract_elements = options[:extract_elements] || VALID_EXTRACT_EXTRACT_ELEMENTS

        unless (renditions_to_extract - RENDITIONS_EXTRACTS).empty?
          raise ArgumentError,
                "Invalid renditions_to_extract: #{renditions_to_extract}"
        end
        unless TABLE_OUTPUT_FORMATS.include?(table_output_format)
          raise ArgumentError,
                "Invalid table_output_format: #{table_output_format}"
        end
        return if (extract_elements - VALID_EXTRACT_EXTRACT_ELEMENTS).empty?

        raise ArgumentError,
              "Invalid extract_elements: #{extract_elements - VALID_EXTRACT_EXTRACT_ELEMENTS}"
      end

      def handle_response(response)
        result_class.new(JSON.parse(response.body), nil)
      end

      def result_class
        Result
      end
    end
  end
end
