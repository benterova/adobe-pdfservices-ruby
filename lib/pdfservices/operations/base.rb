# frozen_string_literal: true

module PdfServices
  module Base
    class Operation
      BASE_ENDPOINT = 'https://pdf-services-ue1.adobe.io/operation/'
      ASSETS_ENDPOINT = 'https://pdf-services-ue1.adobe.io/assets/'
      STATUS = {
        in_progress: 'in progress',
        done: 'done',
        failed: 'failed'
      }.freeze

      def initialize(api)
        @api = api
      end

      def upload_asset(asset)
        if asset.is_a?(String) && File.exist?(asset)
          asset = File.open(asset, 'rb')
        elsif asset.respond_to?(:read) && asset.respond_to?(:eof?)
          tempfile = Tempfile.new(['blob', SecureRandom.uuid])
          tempfile.write(asset.read(1024)) until asset.eof?
          tempfile.rewind
          asset = tempfile
        end
        Asset.new(@api).upload(asset)
      end

      def poll_document_result(url, original_asset, &block)
        response = @api.get(url)
        json_response = JSON.parse(response.body.to_s)
        handle_polling_result(url, json_response, original_asset, &block)
      end

      def handle_response(response, asset, &block)
        unless response.status == 201
          raise "Unexpected response status from operation endpoint: #{response.status}, #{response.body}"
        end

        document_url = response.headers['location']
        poll_document_result document_url, asset, &block
      end

      private

      def handle_polling_result(url, json_response, original_asset, &block)
        case json_response['status']
        when STATUS[:in_progress]
          handle_in_progress(url, json_response, original_asset, &block)
        when STATUS[:done]
          handle_done(json_response, original_asset, &block)
        when STATUS[:failed]
          handle_failed(json_response, original_asset, &block)
        else
          handle_unexpected_status(json_response, original_asset, &block)
        end
      end

      def handle_in_progress(url, json_response, original_asset, &block)
        block.call(json_response['status'], nil) if block_given?
        sleep(1) # Consider a more sophisticated retry strategy
        poll_document_result(url, original_asset, &block)
      end

      def handle_done(json_response, original_asset, &block)
        return block.call(json_response['status'], handle_polling_done(json_response, original_asset)) if block_given?

        handle_polling_done(json_response, original_asset)
      end

      def handle_failed(json_response, original_asset, &block)
        block.call(json_response['status'], nil) if block_given?
        handle_polling_failed(json_response, original_asset)
      end

      def handle_unexpected_status(json_response, original_asset, &block)
        block.call(json_response['status'], nil) if block_given?
        handle_polling_unexpected_status(json_response, original_asset)
      end

      def handle_polling_done(_json_response, original_asset)
        original_asset.delete_asset
      end

      def handle_polling_failed(json_response, original_asset)
        original_asset.delete_asset
        raise PollingError, "Document extraction failed: #{json_response['error']}"
      end

      def handle_polling_unexpected_status(json_response, original_asset)
        original_asset.delete_asset
        raise PollingError, "Unexpected status: #{json_response['status']}"
      end
    end
  end
end
