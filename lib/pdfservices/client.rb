# frozen_string_literal: true

module PdfServices
  # Represents a client for interacting with PDF services.
  class Client
    TOKEN_ENDPOINT = 'https://pdf-services.adobe.io/token'
    attr_reader :client_id

    include Ocr::Operation
    include HtmlToPdf::Operation
    include DocumentMerge::Operation
    include ExtractPdf::Operation

    def initialize(client_id, client_secret, access_token = nil)
      @client_id = client_id
      @client_secret = client_secret
      @access_token = access_token
      @expires_at = Time.now
    end

    def access_token
      refresh_token if @access_token.nil? || Time.now >= @expires_at
      @access_token
    end

    def api
      @api ||= Api.new(self)
    end

    private

    def refresh_token
      response = RestClient.post(TOKEN_ENDPOINT, form: {
                                   client_id: @client_id,
                                   client_secret: @client_secret
                                 })
      raise JSON.parse(response.body.to_s).fetch('error_description', 'unknown error') unless response.code == 200

      response_json = JSON.parse(response.body.to_s)
      @access_token = response_json['access_token']
      @expires_at = Time.now + response_json['expires_in'].to_i
    end
  end
end
