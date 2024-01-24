# frozen_string_literal: true

module PdfServices
  module DocumentGeneration
    class Internal < Operation
      INTERNAL_OPTIONS = %i[output_format json_data_for_merge fragments notifiers].freeze

      def execute(template_path, options = {})
        validate_options(options)
        asset = upload_asset(template_path)

        response = @api.post(OPERATION_ENDPOINT,
                             body: request_body(asset.id, options),
                             headers: request_headers)

        handle_response(response, asset.id)
      end

      private

      def request_body(asset_id, options)
        body = {
          assetID: asset_id,
          outputFormat: options.fetch(:output_format, 'pdf'),
          jsonDataForMerge: options.fetch(:json_data_for_merge, {})
        }
        body[:fragments] = options[:fragments] if options[:fragments]
        body[:notifiers] = options[:notifiers] if options[:notifiers]
        body
      end

      def validate_options(options)
        raise ArgumentError, 'Invalid options' unless options.is_a?(Hash)

        validate_output_format(options[:output_format])
        validate_fragments(options[:fragments])
        validate_notifiers(options[:notifiers])
        validate_keys(options)
        validate_json_data_for_merge(options[:json_data_for_merge])
      end

      def validate_output_format(output_format)
        raise ArgumentError, "Invalid output format: #{output_format}" unless %w[pdf docx].include?(output_format)
      end

      def validate_fragments(fragments)
        raise ArgumentError, 'Invalid fragments, must be a hash' unless fragments.is_a?(Hash) || fragments.nil?
      end

      def validate_notifiers(notifiers)
        return if notifiers.is_a?(Array) || notifiers.nil?

        raise ArgumentError,
              'Invalid notifiers, must be an array of hashes'
      end

      def validate_json_data_for_merge(json_data_for_merge)
        raise ArgumentError, 'Invalid json_data_for_merge, must be a hash' unless json_data_for_merge.is_a?(Hash)
      end

      def validate_keys(options)
        valid_keys = INTERNAL_OPTIONS
        invalid_keys = options.keys - valid_keys
        raise ArgumentError, "Invalid options: #{invalid_keys}" unless invalid_keys.empty?
      end

      def handle_polling_done(json_response, original_asset)
        asset_id = json_response['asset']['assetID']
        file = Asset.new(@api).download(asset_id).body
        super
        file
      end
    end
  end
end
