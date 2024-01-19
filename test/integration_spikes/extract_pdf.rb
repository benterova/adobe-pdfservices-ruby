# frozen_string_literal: true

require 'dotenv/load'
require_relative '../../lib/pdfservices'

credentials = PdfServices::CredentialsBuilder.new
                                             .with_client_id(ENV['PDF_SERVICES_CLIENT_ID'])
                                             .with_client_secret(ENV['PDF_SERVICES_CLIENT_SECRET'])
                                             .with_organization_id(ENV['PDF_SERVICES_ORGANIZATION_ID'])
                                             .build

pdf = File.join(Dir.pwd, 'test', 'fixtures', 'files', 'not_yet_extracted.pdf')
operation = PdfServices::ExtractPdf::Operation.new(credentials, pdf)

result = operation.execute

puts(result.error)

result.save_as_file('tmp/extract_pdf_result.json')
