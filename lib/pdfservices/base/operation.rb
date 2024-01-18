# frozen_string_literal: true

require "http"
require "pdfservices/jwt_provider"
require "yaml"

module PdfServices
  module Base
    class Operation
      PRESIGNED_URL_ENDPOINT = "https://pdf-services.adobe.io/assets"
      ASSETS_ENDPOINT = "https://pdf-services.adobe.io/assets"

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

      def poll_document_result(url, original_asset_id)
        sleep(1)
        response = api.get(url)
        if response.status == 200
          json_response = JSON.parse(response.body.to_s)
          ocr_asset_id = json_response&.[]("asset")&.[]("assetID")
          case json_response["status"]
          when "in progress"
            poll_document_result(url, original_asset_id)
          when "done"
            # download_the_asset
            response = HTTP.get(json_response["asset"]["downloadUri"])
            # delete the assets
            delete_the_asset(original_asset_id) if !original_asset_id.nil?
            delete_the_asset(ocr_asset_id) if !ocr_asset_id.nil?
            # return the result
            result_class.new(response.body, nil)
          when "failed"
            # delete the original asset
            delete_the_asset(original_asset_id) if !original_asset_id.nil?
            result_class.new(nil, "OCR Failed")
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
