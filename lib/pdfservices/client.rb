# frozen_string_literal: true

module PdfServices
  class Client
    TOKEN_ENDPOINT = 'https://pdf-services-ue1.adobe.io/token'
    DEFAULT_TOKEN_DURATION = 86_399
    attr_reader :expires_at

    def initialize(client_id = nil, client_secret = nil, access_token = nil)
      @client_id = client_id
      @client_secret = client_secret
      @access_token = access_token
      @expires_at = Time.now + DEFAULT_TOKEN_DURATION
      valid_access_token? ? access_token : refresh_token
      validate_client
      @api = Api.new(@access_token, @client_id)
    end

    def method_missing(method_name, *args, &block)
      operation_class_name = "PdfServices::#{camelize(method_name.to_s)}::Operation"
      if Object.const_defined? operation_class_name
        operation_class = Object.const_get operation_class_name
        operation = operation_class.new @api
        operation.execute(*args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      operation_class_name = "PdfServices::#{camelize(method_name.to_s)}::Operation"
      Object.const_defined?(operation_class_name) || super
    end

    private

    def camelize(str)
      str.split('_').map(&:capitalize).join
    end

    def validate_client
      raise 'Client ID and Client Secret are required' if (@client_id.nil? || @client_secret.nil?) && @access_token.nil?
    end

    def valid_access_token?
      !@access_token.nil? && Time.now <= @expires_at
    end

    def refresh_token
      response = Faraday.post(TOKEN_ENDPOINT) do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = {
          client_id: @client_id,
          client_secret: @client_secret
        }
        unless response.status == 200
          raise ClientError,
                "Something went wrong when trying to refresh the token: #{response.body}"
        end
      end

      raise "Token refresh error: #{response.status} - #{response.body}" unless response.status == 200

      response_json = JSON.parse(response.body)
      @access_token = response_json['access_token']
      @expires_at = Time.now + response_json['expires_in'].to_i
    end
  end
end
