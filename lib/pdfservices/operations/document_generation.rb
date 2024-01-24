# frozen_string_literal: true

module PdfServices
  module DocumentGeneration
    class Operation < InternalExternalOperation::Operation
      OPERATION_ENDPOINT = "#{BASE_ENDPOINT}documentgeneration".freeze

      def request_headers
        { 'Content-Type' => 'application/json' }
      end

      def handle_response(response, asset_id)
        unless response.status == 201
          raise "Unexpected response status from document merge endpoint: #{response.status}, asset_id: #{asset_id}"
        end

        document_url = response.headers['location']
        poll_document_result document_url, asset_id
      end

      def internal_class
        Internal
      end

      def external_class
        External
      end
    end
  end
end
