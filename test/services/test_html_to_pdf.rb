# frozen_string_literal: true

require 'test_helper'

class HtmlToPdfTest < Minitest::Test
  def test_it_works
    stub_valid_response_sequence

    # Initial setup, create credentials instance.
    credentials = valid_credentials

    # Data for the document merge process
    json_string = file_fixture('sample_data.json')
    json_data_for_merge = JSON.parse(json_string)

    # template source file
    zip_file_path = File.join(Dir.pwd, 'test', 'fixtures', 'files', 'sample.zip')

    operation = ::PdfServices::HtmlToPdf::Operation.new(
      credentials,
      zip_file_path,
      json_data_for_merge
    )
    # Execute the operation
    result = operation.execute

    assert result.success?
  end
end
