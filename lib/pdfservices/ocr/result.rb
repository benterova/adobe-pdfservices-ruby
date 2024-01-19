require "json"
require "multipart_parser/reader"
require_relative "../base/result"

module PdfServices
  module Ocr
    class Result < Base::Result
      # Created to maintain compatibility with existing tests
      def document_body
        @document
      end
    end
  end
end
