# frozen_string_literal: true

require "test_helper"

class ExtractPdfTest < Minitest::Test
  def test_it_works
    stub_valid_response_sequence

    # Initial setup, create credentials instance.
    credentials = valid_credentials

    # Source file
    source_pdf_path = File.join(Dir.pwd, "test", "fixtures", "files", "not_yet_extracted.pdf")

    operation = ::PdfServices::ExtractPdf::Operation.new(
      credentials,
      source_pdf_path,
      renditions_to_extract: ["tables", "figures"],
      table_output_format: "csv",
      include_styling: false,
      extract_elements: ["tables", "text"],
      get_char_bounds: false
    )

    # Execute the operation
    result = operation.execute
    expected = { "content" => "expected content from the extracted pdf" }

    assert result.success?
    assert_equal expected, JSON.parse(result.document.to_s)
  end

  private

  def stub_valid_response_sequence
    # Mock API responses
    # Replace with appropriate mock responses for the Extract PDF operation

    # Mock JWT token exchange
    stub_request(:post, "https://ims-na1.adobelogin.com/ims/exchange/jwt/")
      .to_return(status: 200, body: json_fixture("valid_jwt_response"))

    # Mock asset upload
    stub_request(:post, "https://pdf-services.adobe.io/assets")
      .with(headers: secured_headers)
      .to_return(
        status: 200,
        headers: json_headers,
        body: json_fixture("presigned_upload_url_response")
      )

    # Mock source PDF upload
    stub_request(:put, "https://a.presigned.url").to_return(status: 200)

    # Mock Extract PDF operation request
    stub_request(:post, "https://pdf-services.adobe.io/operation/extractpdf")
      .with(headers: secured_headers)
      .to_return(
        status: 201,
        headers: { "location" => "https://some.polling.url" }.merge(json_headers)
      )

    # Mock polling for the result
    stub_request(:get, "https://some.polling.url")
      .with(headers: secured_headers)
      .to_return(status: 200, headers: json_headers, body: json_fixture("extract_pdf_in_progress"))
      .to_return(status: 200, headers: json_headers, body: json_fixture("extract_pdf_done"))

    # Mock download of the extracted PDF
    stub_request(:get, "https://extracted.file.url")
      .to_return(status: 200, headers: json_headers, body: file_fixture("fake_extract_done.json"))

    # Mock deletion of the original and extracted assets
    stub_request(:delete, "https://pdf-services.adobe.io/assets/urn:a-real-long-asset-asset-id")
      .with(headers: secured_headers)
      .to_return(status: 200, body: "", headers: {})
    stub_request(:delete, "https://pdf-services.adobe.io/assets/extracted:asset-id")
      .with(headers: secured_headers)
      .to_return(status: 200, body: "", headers: {})
  end

  def secured_headers
    {
      Authorization: "Bearer fake1.fake2.fake3",
      "Content-Type": "application/json",
      "X-Api-Key": "123someclientid"
    }
  end

  def json_headers
    { "Content-Type" => "application/json;charset=UTF-8" }
  end

  def pdf_headers
    { "Content-Type" => "application/pdf" }
  end

  def secured_headers
    {
      Authorization: "Bearer fake1.fake2.fake3",
      "Content-Type": "application/json",
      "X-Api-Key": "123someclientid"
    }
  end

  def json_headers
    { "Content-Type" => "application/json;charset=UTF-8" }
  end

  def pdf_headers
    { "Content-Type" => "application/pdf" }
  end
end
