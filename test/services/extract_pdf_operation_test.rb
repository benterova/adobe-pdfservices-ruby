require 'test_helper'
require_relative '../../lib/pdfservices/extract_pdf/operation'

class ExtractPdfOperationTest < Minitest::Test
  def setup
    setup_stubs
    setup_client
  end

  def test_extract_pdf_with_valid_options
    response = @client.extract_pdf('source.pdf', renditions_to_extract: ['text'], table_output_format: 'csv',
                                                 extract_elements: ['tables'])
    assert_equal json_fixture('extractpdf_done'), response.job_location
  end

  def test_extract_pdf_with_invalid_options
    assert_raises(ArgumentError) do
      @client.extract_pdf('source.pdf', renditions_to_extract: ['invalid_rendition'])
    end

    assert_raises(ArgumentError) do
      @client.extract_pdf('source.pdf', table_output_format: 'invalid_format')
    end

    assert_raises(ArgumentError) do
      @client.extract_pdf('source.pdf', extract_elements: ['invalid_element'])
    end
  end
end
