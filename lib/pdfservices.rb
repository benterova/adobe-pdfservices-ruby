# frozen_string_literal: true

require 'json'
require 'multipart_parser/reader'
require 'yaml'
require 'faraday'

# Errors
require_relative 'pdfservices/errors'

# Asset
require_relative 'pdfservices/asset'

# Base
require_relative 'pdfservices/operations/base'

# Document Merge
require_relative 'pdfservices/operations/document_merge'

# OCR
require_relative 'pdfservices/operations/ocr'

# HTML to PDF
require_relative 'pdfservices/operations/html_to_pdf'

# Extract PDF
require_relative 'pdfservices/operations/extract_pdf'

# Client and API
require_relative 'pdfservices/client'
require_relative 'pdfservices/api'
