module PdfServices
  class Asset
    ASSETS_ENDPOINT = 'https://pdf-services.adobe.io/assets'.freeze

    attr_reader :id

    def initialize(api, id = nil)
      raise ArgumentError, 'Api is nil' unless api

      @api = api
      @id = id
    end

    def upload(file)
      url = presigned_url
      upload_uri = url['uploadUri']
      asset_id = url['assetID']

      response = @api.put(upload_uri, body: File.new(file))

      raise AssetError, 'Something went wrong when trying to upload the file' unless response.status == 200

      @id = asset_id

      self
    end

    def download(asset_id = nil)
      raise AssetError, 'Asset ID is nil' unless @id || asset_id
      raise AssetError, "Asset ID is not a string, is a #{@id.class}" unless (@id || asset_id).respond_to?(:to_s)

      @id = asset_id if asset_id

      url = presigned_url('download')
      download_uri = url['downloadUri']
      @api.get(download_uri)
    end

    def delete
      raise AssetError, 'Asset ID is nil' unless @id

      @api.delete("#{ASSETS_ENDPOINT}/#{@id}")
    end

    private

    def presigned_url(operation = 'upload', media_type: 'application/pdf')
      case operation
      when 'upload'
        response = @api.post(ASSETS_ENDPOINT, body: { mediaType: media_type })
      when 'download'
        response = @api.get("#{ASSETS_ENDPOINT}/#{@id}")
      end
      JSON.parse response.body.to_s
    end
  end
end
