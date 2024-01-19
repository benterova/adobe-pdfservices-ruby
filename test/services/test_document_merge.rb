# frozen_string_literal: true

require 'test_helper'

class DocumentMergeTest < Minitest::Test
  def test_it_works
    # Initial setup, create credentials instance.
    credentials = valid_credentials

    # Data for the document merge process
    json_string = file_fixture('sample_data.json')
    json_data_for_merge = JSON.parse(json_string)

    # template source file
    template_path = File.join(Dir.pwd, 'test', 'fixtures', 'files', 'sample_template.docx')

    operation = ::PdfServices::DocumentMerge::Operation.new(
      credentials,
      template_path,
      json_data_for_merge,
      :pdf
    )
    # Execute the operation
    result = operation.execute

    assert result.success?
  end
end
