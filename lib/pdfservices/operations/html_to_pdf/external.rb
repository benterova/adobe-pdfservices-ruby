# frozen_string_literal: true

module PdfServices
  module HtmlToPdf
    class External < Operation
      EXTERNAL_OPTIONS = %i[input output params download_from_external].freeze
      INPUT_KEYS = %i[uri storage].freeze
      OUTPUT_KEYS = %i[uri storage].freeze
      PARAMS_KEYS = %i[include_header_footer json page_layout].freeze
      STORAGE_OPTIONS = %i[S3 SHAREPOINT DROPBOX BLOB].freeze

      def initialize(api)
        super
        @download_from_external = false
        @download_uri = nil
      end

      def execute(template_path, options = {})
        @download_from_external = options[:download_from_external] || false
        validate_options(options)
        asset = upload_asset(template_path)

        @download_uri = options[:output][:uri] if @download_from_external

        response = @api.post(OPERATION_ENDPOINT,
                             body: request_body(asset.id, options),
                             headers: request_headers)
        handle_response(response, asset.id)
      end

      private

      def request_body(asset_id, options)
        {
          assetID: asset_id,
          input: camelize_keys(options[:input]),
          output: camelize_keys(options[:output]),
          params: camelize_keys(options[:params])
        }
      end

      def handle_polling_done(_json_response, original_asset)
        file = @api.get(@download_uri).body if @download_from_external
        super
        file || true
      end

      def validate_options(options)
        raise ArgumentError, 'Options must be a hash' unless options.is_a?(Hash)

        validate_required_keys(options)
        validate_input_options(options[:input])
        validate_output_options(options[:output])
      end

      def validate_required_keys(options)
        required_keys = EXTERNAL_OPTIONS - %i[download_from_external]
        required_keys.each do |key|
          raise ArgumentError, "Missing required key: #{key}" unless options.key?(key)
        end
      end

      def validate_input_options(input_options)
        raise ArgumentError, 'Input options must be a hash' unless input_options.is_a?(Hash)

        required_input_keys = INPUT_KEYS
        required_input_keys.each do |key|
          raise ArgumentError, "Missing required input key: #{key}" unless input_options.key?(key)
        end
        validate_storage_options(input_options[:storage])
      end

      def validate_output_options(output_options)
        raise ArgumentError, 'Output options must be a hash' unless output_options.is_a?(Hash)

        unless output_options.key?(:uri) && @download_from_external
          raise ArgumentError,
                'Output options must contain uri when downloading from external storage'
        end

        required_output_keys = OUTPUT_KEYS - %i[uri]
        required_output_keys.each do |key|
          raise ArgumentError, "Missing required output key: #{key}" unless output_options.key?(key)
        end
        validate_storage_options(output_options[:storage])
      end

      def validate_storage_option(storage_option)
        return if STORAGE_OPTIONS.include?(storage_option)

        raise ArgumentError,
              "Invalid storage option: #{storage_option}"
      end
    end
  end
end
