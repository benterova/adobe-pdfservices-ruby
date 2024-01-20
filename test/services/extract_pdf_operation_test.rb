require 'test_helper'

class ExtractPdfOperationTest < Minitest::Test
  def setup
    setup_stubs
    setup_client
  end

  def test_extract_pdf_with_valid_options
    result = @client.extract_pdf(file_fixture_path('not_yet_extracted.pdf'), renditions_to_extract: ['tables'], table_output_format: 'csv',
                                                                             extract_elements: ['text'])
    assert_equal JSON.parse(json_fixture('extractpdf_done')), result.body
    puts 'Valid test: Success'
  end

  def test_extract_pdf_with_invalid_options
    source = file_fixture_path('not_yet_extracted.pdf')
    assert_raises(ArgumentError) do
      @client.extract_pdf(source, renditions_to_extract: ['invalid_rendition'])
    end

    assert_raises(ArgumentError) do
      @client.extract_pdf(source, table_output_format: 'invalid_format')
    end

    assert_raises(ArgumentError) do
      @client.extract_pdf(source, extract_elements: ['invalid_element'])
    end

    puts 'Invalid test: Success'
  end
end
