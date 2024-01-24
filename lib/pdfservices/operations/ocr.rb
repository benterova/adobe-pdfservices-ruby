# frozen_string_literal: true

module PdfServices
  module Ocr
    class Operation < InternalExternalOperation::Operation
      OCR_ENDPOINT = 'https://pdf-services-ue1.adobe.io/operation/ocr'
      OCR_LANGS = %w[
        da-DK lt-LT sl-SI el-GR ru-RU en-US zh-HK hu-HU et-EE
        pt-BR uk-UA nb-NO pl-PL lv-LV fi-FI ja-JP es-ES bg-BG
        en-GB cs-CZ mt-MT de-DE hr-HR sk-SK sr-SR ca-CA mk-MK
        ko-KR de-CH nl-NL zh-CN sv-SE it-IT no-NO tr-TR fr-FR
        ro-RO iw-IL
      ].freeze

      OCR_TYPES = %w[searchable_image searchable_image_exact].freeze

      def execute(source_pdf)
        asset_id = upload_asset(source_pdf)
        response = @api.post(OCR_ENDPOINT, json: { assetID: asset_id })

        if response.status == 201
          document_url = response.headers['location']
          poll_document_result(document_url, asset_id) do |response|
            handle_ocr_response(response)
          end
        else
          Result.new(nil, "Unexpected response status from OCR endpoint: #{response.status}\nasset_id: #{asset_id}")
        end
      end

      private

      def handle_ocr_response(response)
        download_uri = @api.get(response['asset']['downloadUri'])
        Result.new(download_uri.body, nil)
      end

      def validate_ocr_lang_option(ocr_lang)
        raise ArgumentError, "Invalid ocr_lang option: #{ocr_lang}" unless OCR_LANGS.include?(ocr_lang)
      end

      def validate_ocr_type_option(ocr_type)
        raise ArgumentError, "Invalid ocr_type option: #{ocr_type}" unless OCR_TYPES.include?(ocr_type)
      end
    end
  end
end
