# frozen_string_literal: true

module PdfServices
  module DocumentGeneration
    class Operation < InternalExternalOperation::Operation
      OPERATION_ENDPOINT = "#{BASE_ENDPOINT}documentgeneration".freeze

      def request_headers
        { 'Content-Type' => 'application/json' }
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
