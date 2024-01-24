# frozen_string_literal: true

module PdfServices
  module HtmlToPdf
    class Internal < Operation
      INTERNAL_OPTIONS = %i[input_url json include_header_footer page_layout notifiers].freeze
      PAGE_LAYOUT_OPTIONS = %i[page_width page_height].freeze

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
          assetID: asset_id,
          inputUrl: options.fetch(:input_url, ''),
          pageLayout: camelize_keys(options.fetch(:page_layout, {})),
          json: transform_json(options.fetch(:json, ''))
        }
        body[:fragments] = options[:fragments] if options[:fragments]
        body[:notifiers] = options[:notifiers] if options[:notifiers]
        body
      end

      def transform_json(json)
        json.is_a?(String) ? json : json.to_json
      end

      def validate_options(options)
        raise ArgumentError, 'Invalid options' unless options.is_a?(Hash)

        options.each_key do |key|
          raise ArgumentError, "Invalid option: #{key}" unless INTERNAL_OPTIONS.include?(key)
        end

        validate_page_layout_options(options[:page_layout]) if options[:page_layout]
      end

      def validate_required_keys(options)
        required_keys = INTERNAL_OPTIONS - %i[page_layout notifiers]
        required_keys.each do |key|
          raise ArgumentError, "Missing required option: #{key}" unless options.key?(key)
        end
      end

      def validate_page_layout_options(options)
        raise ArgumentError, 'Invalid page layout options' unless options.is_a?(Hash)

        options.each_key do |key|
          raise ArgumentError, "Invalid page layout option: #{key}" unless PAGE_LAYOUT_OPTIONS.include?(key)
        end
      end
    end
  end
end
