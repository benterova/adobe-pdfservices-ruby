# frozen_string_literal: true

module PdfServices
  module ExtractPdf
    class Operation < Base::Operation
      OPERATION_ENDPOINT = "#{BASE_ENDPOINT}extractpdf".freeze
      VALID_EXTRACT_ELEMENTS = %w[tables text].freeze
      TABLE_OUTPUT_FORMATS = %w[csv xlsx].freeze
      RENDITIONS_EXTRACTS = %w[tables figures].freeze

      def execute(source_pdf = nil, options = {})
        validate_options(options)
        asset = upload_asset(source_pdf)

        response = @api.post(OPERATION_ENDPOINT, body: extract_pdf_request_body(asset.id, options),
                                                 headers: extract_pdf_request_headers)
        handle_extract_pdf_response(response, asset)
      end

      private

      def extract_pdf_request_body(asset_id, options)
        {
          assetID: asset_id,
          includeStyling: options.fetch(:include_styling, false),
          getCharBounds: options.fetch(:get_char_bounds, false),
          renditions: options.fetch(:renditions_to_extract, RENDITIONS_EXTRACTS),
          tableOutputFormat: options.fetch(:table_output_format, TABLE_OUTPUT_FORMATS.first),
          extractElements: options.fetch(:extract_elements, VALID_EXTRACT_ELEMENTS)
        }
      end

      def extract_pdf_request_headers
        { 'Content-Type' => 'application/json' }
      end

      def handle_extract_pdf_response(response, asset)
        raise OperationError, "Extract PDF operation failed: #{response.body}" unless response.status == 201

        document_url = response.headers['location']
        poll_document_result(document_url, asset)
      end

      def handle_polling_done(json_response, original_asset)
        asset_id = json_response['content']['assetID']
        file = Asset.new(@api).download(asset_id)
        super
        file.body
      end

      def validate_options(options)
        validate_renditions_to_extract(options[:renditions_to_extract])
        validate_table_output_format(options[:table_output_format])
        validate_extract_elements(options[:extract_elements])
      end

      def validate_renditions_to_extract(renditions_to_extract)
        renditions_to_extract ||= RENDITIONS_EXTRACTS
        return if (renditions_to_extract - RENDITIONS_EXTRACTS).empty?

        raise ArgumentError, "Invalid renditions_to_extract: #{renditions_to_extract}"
      end

      def validate_table_output_format(table_output_format)
        table_output_format ||= TABLE_OUTPUT_FORMATS.first
        return if TABLE_OUTPUT_FORMATS.include?(table_output_format)

        raise ArgumentError, "Invalid table_output_format: #{table_output_format}"
      end

      def validate_extract_elements(extract_elements)
        extract_elements ||= VALID_EXTRACT_ELEMENTS
        invalid_elements = extract_elements - VALID_EXTRACT_ELEMENTS
        return if invalid_elements.empty?

        raise ArgumentError, "Invalid extract_elements: #{invalid_elements}"
      end
    end
  end
end
