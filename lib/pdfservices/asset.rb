module PdfServices
  class Asset
    ASSETS_ENDPOINT = 'https://pdf-services-ue1.adobe.io/assets'.freeze

    attr_reader :id

    def initialize(api, id = nil)
      # MimeMagic can't detect docx files, and will return `application/zip` so we need to add it manually
      MimeMagic.add('application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                    magic: [[0..2000, 'word/']])
      raise ArgumentError, 'Api is nil' unless api

      @api = api
      @id = id
    end

    def upload(file)
      url = presigned_url(file:)
      upload_uri = url['uploadUri']
      asset_id = url['assetID']

      response = @api.put(upload_uri, body: File.new(file), headers: upload_headers(File.new(file)))

      unless response.status == 200
        raise AssetError,
              "Something went wrong when trying to upload the file: #{response.body.inspect}"
      end

      @id = asset_id

      self
    end

    def download(asset_id = nil)
      raise AssetError, 'Asset ID is nil' unless @id || asset_id
      raise AssetError, "Asset ID is not a string, is a #{@id.class}" unless (@id || asset_id).respond_to?(:to_s)

      @id = asset_id if asset_id

      url = presigned_url(:download)
      download_uri = url['downloadUri']
      @api.get(download_uri)
    end

    def delete_asset
      raise AssetError, 'Asset ID is nil' unless @id

      @api.delete("#{ASSETS_ENDPOINT}/#{@id}")
    end

    private

    def upload_headers(file)
      {
        'Content-Type' => MimeMagic.by_magic(file).type,
        'Content-Length' => file.size.to_s
      }
    end

    def presigned_url(operation = :upload, file: nil)
      case operation
      when :upload
        media_type = file ? MimeMagic.by_magic(file).type : 'application/pdf'
        response = @api.post(ASSETS_ENDPOINT, body: { mediaType: media_type },
                                              headers: { 'Content-Type' => 'application/json' })
      when :download
        response = @api.get("#{ASSETS_ENDPOINT}/#{@id}")
      end

      unless response.status == 200
        raise AssetError,
              "Something went wrong when trying to get the presigned URL: #{JSON.parse(response.body)}"
      end

      JSON.parse response.body.to_s
    end
  end
end
