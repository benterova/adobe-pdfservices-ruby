require "http"
require "pdfservices/jwt_provider"
require "yaml"

module PdfServices
  module ExtractPdf
    class Operation < Base::Operation
      OPERATION_ENDPOINT = "https://pdf-services.adobe.io/operation/extractpdf"

      def initialize(credentials = nil)
        super(credentials)
      end
    end
  end
end
