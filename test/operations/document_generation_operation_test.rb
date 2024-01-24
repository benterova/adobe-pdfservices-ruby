require 'test_helper'

class DocumentGenerationOperationTest < Minitest::Test
  def setup
    setup_stubs
    setup_client
  end

  def test_internal_document_generation_with_valid_options
    file = @client.document_generation(file_fixture_path('documentgeneration_template.docx'), {
                                         output_format: 'pdf',
                                         json_data_for_merge: JSON.parse(file_fixture('documentgeneration_merge_data.json'))
                                       })

    assert_equal file_fixture('documentgeneration_download_response'), file
  end

  def test_internal_document_generation_with_invalid_options
    template = file_fixture_path('documentgeneration_template.docx')
    assert_raises(ArgumentError) do
      @client.document_generation(template, { output_format: 'invalid_format' })
    end

    assert_raises(ArgumentError) do
      @client.document_generation(template, { json_data_for_merge: 'invalid_json' })
    end

    assert_raises(ArgumentError) do
      @client.document_generation(template, { fragments: 'invalid_fragments' })
    end

    assert_raises(ArgumentError) do
      @client.document_generation(template, { notifiers: 'invalid_notifiers' })
    end
  end
end
