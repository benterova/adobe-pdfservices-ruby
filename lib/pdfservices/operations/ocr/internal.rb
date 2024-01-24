# frozen_string_literal: true

module PdfServices
  module Ocr
    class Internal < Operation
      INTERNAL_OPTIONS = %i[ocr_lang ocr_type notifiers].freeze

      def execute(html_file_path, options = {})
        validate_options(options)
        asset = upload_asset(html_file_path)

        response = @api.post(OPERATION_ENDPOINT,
                             body: request_body(asset.id, options),
                             headers: request_headers)

        handle_response(response, asset.id)
      end

      private

      def handle_polling_done(json_response, _original_asset_id)
        asset_id = json_response['asset']['assetID']
        Asset.new(@api).download(asset_id).body
      end

      def request_body(asset_id, options)
        body = {
          assetID: asset_id
        }
        body[:ocrLang] = options[:ocr_lang] if options[:ocr_lang]
        body[:ocrType] = options[:ocr_type] if options[:ocr_type]
        body[:notifiers] = options[:notifiers] if options[:notifiers]
        body
      end

      def validate_options(options)
        raise ArgumentError, 'Invalid options' unless options.is_a?(Hash)

        options.each_key do |key|
          raise ArgumentError, "Invalid option: #{key}" unless INTERNAL_OPTIONS.include?(key)
        end

        validate_ocr_lang_option(options[:ocr_lang]) if options[:ocr_lang]
        validate_ocr_type_option(options[:ocr_type]) if options[:ocr_type]
      end
    end
  end
end
