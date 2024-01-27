# frozen_string_literal: true

module PdfServices
  module HtmlToPdf
    class Internal < Operation
      INTERNAL_OPTIONS = %i[input_url json include_header_footer page_layout notifiers].freeze
      PAGE_LAYOUT_OPTIONS = %i[page_width page_height].freeze

      def execute(html_file_path, options = {}, &block)
        validate_options(options, html_file_path)

        asset = upload_asset(html_file_path) unless options[:input_url]

        asset_id = asset.id if asset

        response = @api.post(OPERATION_ENDPOINT,
                             body: request_body(asset_id, options),
                             headers: request_headers)

        handle_response(response, asset, &block)
      end

      private

      def handle_polling_done(json_response, _original_asset_id)
        asset_id = json_response['asset']['assetID']
        Asset.new(@api).download(asset_id).body
      end

      def request_body(asset_id, options) # rubocop:disable Metrics/AbcSize
        body = {}
        body[:includeHeaderFooter] = options[:include_header_footer] if options[:include_header_footer]
        body[:pageLayout] = options[:page_layout] if options[:page_layout]
        body[:json] = transform_json(options[:json]) if options[:json]
        body[:assetID] = asset_id if asset_id
        body[:inputUrl] = options[:input_url] if options[:input_url]
        body[:notifiers] = options[:notifiers] if options[:notifiers]
        body
      end

      def transform_json(json)
        json.is_a?(String) ? json : json.to_json
      end

      def validate_options(options, source = nil)
        raise ArgumentError, 'Invalid options' unless options.is_a?(Hash)

        options.each_key do |key|
          raise ArgumentError, "Invalid option: #{key}" unless INTERNAL_OPTIONS.include?(key)
        end

        validate_source(source, options)
        validate_page_layout_options(options[:page_layout]) if options[:page_layout]
      end

      def validate_source(source, options)
        raise OperationError, "Cannot specify both 'input_url' and a HTML file" if options[:input_url] && source
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
