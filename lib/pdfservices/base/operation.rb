# frozen_string_literal: true

require "http"
require "pdfservices/jwt_provider"
require "yaml"

module PdfServices
  module Base
    class Operation
      PRESIGNED_URL_ENDPOINT = "https://pdf-services.adobe.io/assets"
      ASSETS_ENDPOINT = "https://pdf-services.adobe.io/assets"
      module Status
        IN_PROGRESS = "in progress"
        DONE = "done"
        FAILED = "failed"
      end

      def initialize(credentials = nil)
        @credentials = credentials
      end

      def upload_asset(asset)
        url = presigned_url
        upload_uri = url["uploadUri"]
        asset_id = url["assetID"]
        aws = HTTP.headers({"Content-Type": "application/pdf"})
        response = aws.put(upload_uri, body: File.open(asset))
        if response.status == 200
          asset_id
        else
          Result.new(nil, "Unexpected response status from asset upload: #{response.status}")
        end
      end

      def delete_the_asset(asset_id)
        api.delete("#{ASSETS_ENDPOINT}/#{asset_id}")
      end

      # Generates a presigned URL for the operation.
      #
      # @return [String] The presigned URL.
      def presigned_url
        response = api.post(PRESIGNED_URL_ENDPOINT, json: {mediaType: "application/pdf"})
        if response.status == 200
          JSON.parse(response.body.to_s)
        else
          Result.new(nil, "Unexpected response status from get presigned url: #{response.status}")
        end
      end

      private

      def api_headers
        {
          Authorization: "Bearer #{JwtProvider.get_jwt(@credentials)}",
          "x-api-key": @credentials.client_id,
          "Content-Type": "application/json"
        }
      end

      def api
        @api ||= HTTP.headers(api_headers)
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
          asset_id = json_response&.[]("asset")&.[]("assetID")
          case json_response["status"]
          when Status::IN_PROGRESS
            sleep(1)
            poll_document_result(url, original_asset_id, &block)
          when Status::DONE
            result = yield(json_response) if block
            # delete the assets
            delete_the_asset(original_asset_id) if !original_asset_id.nil?
            delete_the_asset(asset_id) if !asset_id.nil?
            result
          when Status::FAILED
            # delete the original asset
            delete_the_asset(original_asset_id) if !original_asset_id.nil?
            result_class.new(nil, "Operation Failed")
          else
            # delete the original asset
            delete_the_asset(original_asset_id) if original_asset_id.present?
            result_class.new(nil, "Unexpected status from polling: #{json_response["status"]}")
          end
        else
          # delete the original asset
          delete_the_asset(original_asset_id) if original_asset_id.present?
          result_class.new(nil, "Unexpected response status from polling: #{json_response["status"]}")
        end
      end

      def result_class
        raise NotImplementedError, "Subclasses must implement a result_class method"
      end
    end
  end
end
