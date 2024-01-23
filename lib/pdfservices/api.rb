# frozen_string_literal: true

module PdfServices
  class Api
    attr_accessor :access_token

    def initialize(access_token = nil, client_id = nil)
      @access_token = access_token
      @client_id = client_id

      @connection = Faraday.new do |conn|
        conn.request :url_encoded
        conn.adapter Faraday.default_adapter
      end
    end

    def post(url, body:, headers: {})
      response = @connection.post(url) do |req|
        req.headers = merge_default_headers(headers)
        req.body = body
      end
      handle_response(response)
    end

    def get(url, headers: {})
      response = @connection.get(url) do |req|
        req.headers = merge_default_headers(headers)
      end
      handle_response(response)
    end

    def put(url, body:, headers: {})
      response = @connection.put(url) do |req|
        req.headers = merge_default_headers(headers)
        req.body = body
      end
      handle_response(response)
    end

    def delete(url, headers: {})
      response = @connection.delete(url) do |req|
        req.headers = merge_default_headers(headers)
      end
      handle_response(response)
    end

    private

    def merge_default_headers(headers)
      default_headers = { 'Authorization' => "Bearer #{@access_token}", 'X-Api-Key' => @client_id }
      default_headers.merge(headers)
    end

    def handle_response(response)
      # Implement response handling logic here, like error checking
      response
    end
  end
end
