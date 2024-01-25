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
        build_request(req, headers, body)
      end
      handle_response(response)
    end

    def get(url, headers: {})
      response = @connection.get(url) do |req|
        build_request(req, headers, nil)
      end
      handle_response(response)
    end

    def put(url, body:, headers: {})
      response = @connection.put(url) do |req|
        build_request(req, headers, body)
      end
      handle_response(response)
    end

    def delete(url, headers: {})
      response = @connection.delete(url) do |req|
        build_request(req, headers, nil)
      end
      handle_response(response)
    end

    private

    def build_request(request, headers, body = nil)
      request.body = transform_body(body) if body
      request.headers = build_headers(request, headers)
    end

    def build_headers(request, headers = {})
      default_headers = { 'X-Api-Key' => @client_id }

      # Adobe only allows one authorization type, and presigned URLs already have the token in the URL
      # so we only add the Authorization header if it's not a presigned URL
      default_headers['Authorization'] = "Bearer #{@access_token}" if request.params['X-Amz-Credential'].nil?

      default_headers = default_headers.merge(headers) unless headers.empty?
      default_headers
    end

    def transform_body(body)
      body.is_a?(Hash) ? body.to_json : body
    end

    def handle_response(response)
      # Implement response handling logic here, like error checking
      response
    end
  end
end
