# frozen_string_literal: true

module PdfServices
  class Api
    def initialize(client)
      @client = client
    end

    def post(url, body: nil, json: nil)
      response = HTTP.headers(headers).post(url, body:, json:)
      handle_response(response)
    end

    def get(url)
      response = HTTP.headers(headers).get(url)
      handle_response(response)
    end

    def put(url, body: nil)
      response = HTTP.headers(headers).put(url, body:)
      handle_response(response)
    end

    def delete(url)
      response = HTTP.headers(headers).delete(url)
      handle_response(response)
    end

    private

    def headers
      {
        'Authorization' => "Bearer #{@client.access_token}",
        'x-api-key' => @client.client_id,
        'Content-Type' => 'application/json'
      }
    end

    def handle_response(response)
      # Handle response logic here (e.g., error checking)
      response
    end
  end
end
