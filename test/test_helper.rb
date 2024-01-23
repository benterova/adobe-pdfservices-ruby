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
  PollingStubs.request_with_error
  AssetStubs.presigned_upload_url_request
  AssetStubs.upload_request
  AssetStubs.delete_asset_request
  AssetStubs.download_asset_request
  ClientStubs.access_token_request
  OperationStubs.request
  # OperationStubs.request_with_error
end

module ClientStubs
  module_function

  def access_token_request
    WebMock.stub_request(:post, 'https://pdf-services.adobe.io/token')
           .with(headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
           .to_return(status: 200, body: json_fixture('access_token_response'))
  end
end

module AssetStubs
  include WebMock::API

  module_function

  def presigned_upload_url_request
    WebMock.stub_request(:post, 'https://pdf-services.adobe.io/assets')
           .with(headers: secured_headers)
           .to_return(status: 200, body: json_fixture('presigned_upload_url_response'))
  end

  def upload_request
    WebMock.stub_request(:put, 'https://a.presigned.url')
           .to_return(status: 200)
  end

  def delete_asset_request
    WebMock.stub_request(:delete, %r{https://pdf-services.adobe.io/assets/.*})
           .with(headers: secured_headers)
           .to_return(status: 200, body: '', headers: {})
  end

  def download_asset_request
    WebMock.stub_request(:get, %r{https://.*\file.url})
           .with(headers: secured_headers)
           .to_return(status: 200, body: 'fake pdf', headers: {})
  end
end

module OperationStubs
  module_function

  def request
    WebMock.stub_request(:post, %r{https://pdf-services.adobe.io/operation/.*})
           .with(headers: secured_headers)
           .to_return(->(request) { operation_response(request) })
  end

  def request_with_error
    WebMock.stub_request(:post, %r{https://pdf-services.adobe.io/operation/.*})
           .with(headers: secured_headers)
           .to_return(status: 400, body: json_fixture('operation_request_error'))
  end

  def operation_response(request)
    operation_name = operation_name(request)
    { status: 201, headers: { 'location' => "https://#{operation_name}.polling.url" } }.merge(json_headers)
  end

  def operation_name(request)
    request.uri.path.split('/')[2]
  end
end

module PollingStubs
  include WebMock::API

  module_function

  def request
    WebMock.stub_request(:get, %r{https://.*\.polling.url})
           .with(headers: secured_headers)
           .to_return(->(request) { PollingStubs.response(request) })
           .to_return(->(request) { PollingStubs.response(request) })
           .to_return(->(request) { PollingStubs.done_response(request) })
  end

  def request_with_error
    WebMock.stub_request(:get, %r{https://.*\.polling.url})
           .with(headers: secured_headers)
           .to_return(->(request) { PollingStubs.response(request) })
           .to_return(->(request) { PollingStubs.response(request) })
           .to_return(->(request) { PollingStubs.error_response(request) })
  end

  def response(request)
    operation_name = request.uri
    json_fixture("#{operation_name}_request_in_progress")
  end

  def done_response(request)
    operation_name = request.uri.path.split('/')[1]
    json_fixture("#{operation_name}_request_done")
  end

  def error_response(request)
    operation_name = request.uri.path.split('/')[1]
    json_fixture("#{operation_name}_request_error")
  end
end

def json_fixture(name)
  path = File.join(Dir.pwd, 'test', 'fixtures', "#{name}.json")
  File.read(path)
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
  { Authorization: 'Bearer fake1.fake2.fake3', 'x-api-key': '123someclientid',
    'Content-Type': 'application/json' }
end

def pdf_headers
  { 'Content-Type' => 'application/pdf' }
end
