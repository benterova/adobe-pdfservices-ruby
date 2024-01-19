# frozen_string_literal: true

module PdfServices
  module Base
    class Operation
      PRESIGNED_URL_ENDPOINT = 'https://pdf-services.adobe.io/assets'
      ASSETS_ENDPOINT = 'https://pdf-services.adobe.io/assets'
      module Status
        IN_PROGRESS = 'in progress'
        DONE = 'done'
        FAILED = 'failed'
      end

      def initialize(api = nil)
        raise ArgumentError, 'ApiService must be provided' if api.nil?

        @api = api
      end

      def upload_asset(asset)
        url = presigned_url
        upload_uri = url['uploadUri']
        asset_id = url['assetID']
        aws = HTTP.headers({ "Content-Type": 'application/pdf' })
        response = aws.put(upload_uri, body: File.open(asset))
        if response.status == 200
          asset_id
        else
          Result.new(nil, "Unexpected response status from asset upload: #{response.status}")
        end
      end

      #
      # Polls the document result by making GET requests to the specified URL until the status is either
      # "DONE" or "FAILED". Deletes the original asset and the resulting asset after processing is complete.
      #
      # @param url [String] The URL to poll for the document result.
      # @param original_asset_id [String, nil] The ID of the original asset to delete.
      # @yield [json_response] Optional block to process the JSON response when the status is "DONE".
      # @return [Result] A Result object with the appropriate error message if the operation fails.
      def poll_document_result(url, original_asset_id, &block)
        response = api.get(url)
        if response.status == 200
          json_response = JSON.parse(response.body.to_s)
          asset_id = json_response&.[]('asset')&.[]('assetID')
          handle_polling_result(json_response, original_asset_id, asset_id, &block)
        else
          handle_polling_error(json_response, original_asset_id)
        end
      end

      private

      # Generates a presigned URL for the operation.
      #
      # @return [String] The presigned URL.
      def presigned_url
        response = api.post(PRESIGNED_URL_ENDPOINT, json: { mediaType: 'application/pdf' })
        if response.status == 200
          JSON.parse(response.body.to_s)
        else
          Result.new(nil, "Unexpected response status from get presigned url: #{response.status}")
        end
      end

      def delete_the_asset(asset_id)
        api.delete("#{ASSETS_ENDPOINT}/#{asset_id}")
      end

      def handle_polling_result(json_response, original_asset_id, asset_id, &block)
        case json_response['status']
        when Status::IN_PROGRESS
          sleep(1)
          poll_document_result(url, original_asset_id, &block)
        when Status::DONE
          handle_polling_done(json_response, original_asset_id, asset_id, &block)
        when Status::FAILED
          handle_polling_failed(original_asset_id)
        else
          handle_polling_unexpected_status(json_response, original_asset_id)
        end
      end

      def handle_polling_done(json_response, original_asset_id, asset_id, &block)
        result = yield(json_response) if block
        delete_the_asset(original_asset_id) unless original_asset_id.nil?
        delete_the_asset(asset_id) unless asset_id.nil?
        result
      end

      def handle_polling_failed(original_asset_id)
        delete_the_asset(original_asset_id) unless original_asset_id.nil?
        result_class.new(nil, 'Operation Failed')
      end

      def handle_polling_unexpected_status(json_response, original_asset_id)
        delete_the_asset(original_asset_id) if original_asset_id.present?
        result_class.new(nil, "Unexpected status from polling: #{json_response['status']}")
      end

      def handle_polling_error(json_response, original_asset_id)
        delete_the_asset(original_asset_id) if original_asset_id.present?
        result_class.new(nil, "Unexpected response status from polling: #{json_response['status']}")
      end
    end
  end
end
