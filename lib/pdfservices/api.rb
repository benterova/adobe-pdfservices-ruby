# frozen_string_literal: true

module PdfServices
  class Api
    def initialize(client)
      @client = client
    end

    def post(url, body: nil, content_type: 'application/json')
      body = body.to_json if body.is_a?(Hash) && content_type == 'application/json'
      puts "post url: #{url}, body: #{body}, from: #{caller[0]}"
      response = RestClient.post(url, body, request_headers(content_type))
      handle_response(response)
    end

    def get(url)
      puts "get url: #{url}, from: #{caller[0]}"
      response = RestClient.get(url, request_headers(nil))
      handle_response(response)
    end

    def put(url, body: nil, content_type: 'application/json')
      body = body.to_json if body.is_a?(Hash) && content_type == 'application/json'
      puts "put url: #{url}, body: #{body}, from: #{caller[0]}"
      response = RestClient.put(url, body, request_headers(content_type))
      handle_response(response)
    end

    def delete(url)
      puts "delete url: #{url}, from: #{caller[0]}"
      response = RestClient.delete(url, request_headers(nil))
      handle_response(response)
    end

    private

    def request_headers(content_type)
      headers = {
        'Authorization' => "Bearer #{@client.access_token}",
        'x-api-key' => @client.client_id
      }
      headers['Content-Type'] = content_type if content_type
      headers
    end

    def handle_response(response)
      # Handle response logic here (e.g., error checking)
      response
    end
  end
end
