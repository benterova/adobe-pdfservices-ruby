module PdfServices
  module InternalExternalOperation
    class Operation < Base::Operation
      def execute(source_file_path, options = {})
        operation_class = switch_on_type(options)
        operation_class.new(@api).execute(source_file_path, options)
      end

      private

      def switch_on_type(options)
        type = options[:type] || :internal
        case type
        when :internal
          internal_class
        when :external
          external_class
        end
      end

      def internal_class
        raise NotImplementedError, 'Subclasses must implement this method'
      end

      def external_class
        raise NotImplementedError, 'Subclasses must implement this method'
      end

      def camelize_keys(hash)
        hash.transform_keys { |key| camelize(key.to_s) }
      end

      def camelize(str)
        caps = str.split('_').map(&:capitalize)
        caps[0].downcase!
        caps.join
      end
    end
  end
end
