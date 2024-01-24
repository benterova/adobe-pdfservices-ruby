# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'minitest/autorun'
require 'webmock/minitest'
require 'pdfservices'

def setup_client
  @client = PdfServices::Client.new('123someclientid', 'client_secret')
end

def setup_stubs
  PollingStubs.request
  # PollingStubs.request_with_error
  AssetStubs.presigned_upload_url_request
  AssetStubs.presigned_download_url_request
  AssetStubs.upload_request
  AssetStubs.download_request
  AssetStubs.delete_asset_request
  AssetStubs.download_asset_request
  ClientStubs.access_token_request
  OperationStubs.request
  # OperationStubs.request_with_error
end

module ClientStubs
  module_function

  def access_token_request
    WebMock.stub_request(:post, 'https://pdf-services-ue1.adobe.io/token')
           .with(headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
           .to_return(status: 200, body: json_fixture('access_token_response'))
  end
end

module AssetStubs
  include WebMock::API

  module_function

  def presigned_upload_url_request
    WebMock.stub_request(:post, 'https://pdf-services-ue1.adobe.io/assets')
           .with(headers: secured_headers)
           .to_return(status: 200, body: json_fixture('presigned_upload_url_response'))
  end

  def presigned_download_url_request
    WebMock.stub_request(:get, %r{https://pdf-services-ue1.adobe.io/assets/.*})
           .with(headers: secured_headers)
           .to_return(lambda { |request|
             { status: 200,
               body: json_fixture('presigned_download_url_response', {
                                    'downloadUri' => operation_name(request)
                                  }) }
           })
  end

  def upload_request
    WebMock.stub_request(:put, %r{https://a.presigned.url/assets/.*})
           .to_return(status: 200)
  end

  def download_request
    WebMock.stub_request(:get, %r{https://a.presigned.url/assets/.*})
           .with(headers: secured_headers)
           .to_return(lambda { |request|
                        { status: 200,
                          body: file_fixture("#{operation_name(request)}_download_response") }
                      })
  end

  def delete_asset_request
    WebMock.stub_request(:delete, %r{https://pdf-services-ue1.adobe.io/assets/.*})
           .with(headers: secured_headers)
           .to_return(status: 200, body: '', headers: {})
  end

  def download_asset_request
    WebMock.stub_request(:get, %r{https://.*\file.url})
           .with(headers: secured_headers)
           .to_return(status: 200, body: 'fake pdf', headers: {})
  end

  def operation_name(request)
    request.uri.path.split('/')[2]
  end
end

module OperationStubs
  module_function

  def request
    WebMock.stub_request(:post, %r{https://pdf-services-ue1.adobe.io/operation/.*})
           .with(headers: secured_headers)
           .to_return(->(request) { operation_in_progress_response(request) })
  end

  def request_with_error
    WebMock.stub_request(:post, %r{https://pdf-services-ue1.adobe.io/operation/.*})
           .with(headers: secured_headers)
           .to_return(status: 400, body: json_fixture('operation_request_error'))
  end

  def operation_in_progress_response(request)
    operation_name = operation_name(request)
    { status: 201, headers: { 'location' => "https://polling.url/#{operation_name}" }.merge(json_headers) }
  end

  def operation_name(request)
    request.uri.path.split('/')[2]
  end
end

module PollingStubs
  include WebMock::API

  module_function

  def request
    WebMock.stub_request(:get, %r{https://polling.url/.*})
           .with(headers: secured_headers)
           .to_return(->(request) { PollingStubs.in_progress_response(request) })
           .to_return(->(request) { PollingStubs.in_progress_response(request) })
           .to_return(->(request) { PollingStubs.done_response(request) })
  end

  def request_with_error
    WebMock.stub_request(:get, %r{https://polling.url/.*})
           .with(headers: secured_headers)
           .to_return(->(request) { PollingStubs.in_progress_response(request) })
           .to_return(->(request) { PollingStubs.in_progress_response(request) })
           .to_return(->(request) { PollingStubs.error_response(request) })
  end

  def in_progress_response(request)
    operation_name = operation_name request
    response = OpenStruct.new JSON.parse(json_fixture("#{operation_name}_in_progress"))
    response.body = response.body.to_json
    response
  end

  def done_response(request)
    operation_name = operation_name request
    response = OpenStruct.new JSON.parse(json_fixture("#{operation_name}_done"))
    response.body = response.body.to_json
    response
  end

  def error_response(request)
    operation_name = operation_name request
    response = OpenStruct.new JSON.parse(json_fixture("#{operation_name}_error"))
    response.body = response.body.to_json
    response
  end

  def operation_name(request)
    request.uri.path.split('/')[1]
  end
end

# Allows appending a string to the end of a key's value in a JSON fixture.
# Useful for having unique responses to an operation's download request.
# Example:
#   json_fixture('document_generation_done', { 'asset' => { 'assetID' => '123' } })
#   # => { 'status' => 'done', 'asset' => { 'assetID' => 'abcd123' } }
def json_fixture(name, append = {})
  path = File.join(Dir.pwd, 'test', 'fixtures', "#{name}.json")
  file = File.read(path)
  return unless append

  file_read = JSON.parse(file)
  append.each do |key, value|
    file_read[key] += value
  end
  file_read.to_json
end

def multipart_fixture(name)
  path = File.join(Dir.pwd, 'test', 'fixtures', "#{name}.multipart")
  IO.binread(path)
end

def file_fixture_path(file_name)
  File.join(Dir.pwd, 'test', 'fixtures', 'files', file_name)
end

def file_fixture(file_name)
  File.read(file_fixture_path(file_name))
end

def json_headers
  { 'Content-Type' => 'application/json;charset=UTF-8' }
end

def secured_headers
  { Authorization: 'Bearer fake1.fake2.fake3', 'X-Api-Key': '123someclientid' }
end

def pdf_headers
  { 'Content-Type' => 'application/pdf' }
end
