# frozen_string_literal: true

require 'json'
require 'yaml'
require 'faraday'
require 'mimemagic'
require 'tempfile'
require 'securerandom'

# Errors
require_relative 'pdfservices/errors'

# Asset
require_relative 'pdfservices/asset'

# Base
require_relative 'pdfservices/operations/base'

# Internal/External Operations
require_relative 'pdfservices/operations/internal_external_operation'

# Document Generation
require_relative 'pdfservices/operations/document_generation'
require_relative 'pdfservices/operations/document_generation/internal'
require_relative 'pdfservices/operations/document_generation/external'

# OCR
require_relative 'pdfservices/operations/ocr'
require_relative 'pdfservices/operations/ocr/internal'
require_relative 'pdfservices/operations/ocr/external'

# HTML to PDF
require_relative 'pdfservices/operations/html_to_pdf'
require_relative 'pdfservices/operations/html_to_pdf/internal'
require_relative 'pdfservices/operations/html_to_pdf/external'

# Extract PDF
require_relative 'pdfservices/operations/extract_pdf'

# Client and API
require_relative 'pdfservices/client'
require_relative 'pdfservices/api'
