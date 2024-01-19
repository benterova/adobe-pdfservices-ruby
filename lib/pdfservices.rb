# frozen_string_literal: true

require 'http'
require 'json'
require 'multipart_parser/reader'
require 'yaml'

# Client and API
require_relative 'pdfservices/client'
require_relative 'pdfservices/api'

# Document Merge
require_relative 'pdfservices/document_merge/operation'
require_relative 'pdfservices/document_merge/result'

# OCR
require_relative 'pdfservices/ocr/operation'
require_relative 'pdfservices/ocr/result'

# HTML to PDF
require_relative 'pdfservices/html_to_pdf/operation'
require_relative 'pdfservices/html_to_pdf/result'

# Extract PDF
require_relative 'pdfservices/extract_pdf/operation'
require_relative 'pdfservices/extract_pdf/result'

# Base
require_relative 'pdfservices/base/operation'
require_relative 'pdfservices/base/result'

module PdfServices
  attr_reader :api

  include Ocr::Operation
  include HtmlToPdf::Operation
  include DocumentMerge::Operation
  include ExtractPdf::Operation

  def initialize(credentials = nil)
    @client = Client.new(credentials[:client_id], credentials[:client_secret])
    @api = Api.new(@client)
  end
end
