# frozen_string_literal: true

require 'test_helper'

class OcrTest < Minitest::Test
  def test_it_works
    # Initial setup, create credentials instance.
    credentials = valid_credentials

    # source file
    source_pdf_path = File.join(Dir.pwd, 'test', 'fixtures', 'files', 'not_yet_ocr.pdf')

    operation = ::PdfServices::Ocr::Operation.new(credentials)

    # Execute the operation
    result = operation.execute(source_pdf_path)

    assert result.success?
    assert_equal "this is fake ocr'd pdf\n", result.document_body.to_s
  end
end
