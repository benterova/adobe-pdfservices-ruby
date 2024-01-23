# frozen_string_literal: true

require 'json'
require 'multipart_parser/reader'
require 'yaml'
require 'faraday'

# Base
require_relative 'pdfservices/base/operation'
require_relative 'pdfservices/base/result'

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

# Client and API
require_relative 'pdfservices/client'
require_relative 'pdfservices/api'
