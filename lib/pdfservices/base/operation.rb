# frozen_string_literal: true

module PdfServices
  module Base
    class Operation
      BASE_ENDPOINT = 'https://pdf-services.adobe.io/operation/'
      PRESIGNED_URL_ENDPOINT = 'https://pdf-services.adobe.io/assets'
      ASSETS_ENDPOINT = 'https://pdf-services.adobe.io/assets'
      STATUS = {
        in_progress: 'in progress',
        done: 'done',
        failed: 'failed'
      }.freeze

      def initialize(api)
        @api = api
      end

      def upload_asset(asset)
        url = presigned_url
        upload_uri = url['uploadUri']
        asset_id = url['assetID']
        response = @api.put(upload_uri, body: File.new(asset))

        if response.status == 200
          asset_id
        else
          Result.new(nil,
                     "Unexpected response status from asset upload: #{response.status}")
        end
      end

      def poll_document_result(url, original_asset_id, &block)
        response = @api.get(url)
        return handle_polling_error(response, original_asset_id) unless response.status == 200

        json_response = JSON.parse(response.body.to_s)
        asset_id = json_response['asset']['assetID']
        handle_polling_result(json_response, original_asset_id, asset_id, &block)
      end

      private

      def presigned_url(media_type: 'application/pdf')
        response = @api.post(PRESIGNED_URL_ENDPOINT, body: { mediaType: media_type })
        if response.status == 200
          JSON.parse(response.body.to_s)
        else
          Result.new(nil,
                     "Unexpected response status from get presigned url: #{response.status}")
        end
      end

      def delete_the_asset(asset_id)
        @api.delete("#{ASSETS_ENDPOINT}/#{asset_id}") if asset_id
      end

      def handle_polling_result(json_response, original_asset_id, asset_id, &block)
        case json_response['status']
        when STATUS[:in_progress]
          sleep(1) # Consider a more sophisticated retry strategy
          poll_document_result(url, original_asset_id, &block)
        when STATUS[:done]
          handle_polling_done(json_response, original_asset_id, asset_id, &block)
        when STATUS[:failed]
          handle_polling_failed(original_asset_id)
        else
          handle_polling_unexpected_status(json_response, original_asset_id)
        end
      end

      def handle_polling_done(json_response, original_asset_id, asset_id, &block)
        result = block.call(json_response) if block_given?
        delete_the_asset(original_asset_id)
        delete_the_asset(asset_id)
        result || Result.new(json_response, nil)
      end

      def handle_polling_failed(original_asset_id)
        delete_the_asset(original_asset_id)
        Result.new(nil, 'Operation Failed')
      end

      def handle_polling_unexpected_status(json_response, original_asset_id)
        delete_the_asset(original_asset_id)
        Result.new(nil, "Unexpected status from polling: #{json_response['status']}")
      end

      def handle_polling_error(response, original_asset_id)
        delete_the_asset(original_asset_id)
        Result.new(nil, "Unexpected response status from polling: #{response.status}")
      end
    end
  end
end
