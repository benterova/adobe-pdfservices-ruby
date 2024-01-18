require "json"
require "multipart_parser/reader"
require "pdfservices/base/result"

module PdfServices
  module Ocr
    class Result < Base::Result
      def document_body
        @document
      end
    end
  end
end
