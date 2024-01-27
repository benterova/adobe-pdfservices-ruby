# frozen_string_literal: true

module PdfServices
  module Ocr
    class Operation < InternalExternalOperation::Operation
      OPERATION_ENDPOINT = "#{BASE_ENDPOINT}ocr".freeze
      OCR_LANGS = %w[
        da-DK lt-LT sl-SI el-GR ru-RU en-US zh-HK hu-HU et-EE
        pt-BR uk-UA nb-NO pl-PL lv-LV fi-FI ja-JP es-ES bg-BG
        en-GB cs-CZ mt-MT de-DE hr-HR sk-SK sr-SR ca-CA mk-MK
        ko-KR de-CH nl-NL zh-CN sv-SE it-IT no-NO tr-TR fr-FR
        ro-RO iw-IL
      ].freeze

      OCR_TYPES = %w[searchable_image searchable_image_exact].freeze

      private

      def internal_class
        Internal
      end

      def external_class
        External
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
