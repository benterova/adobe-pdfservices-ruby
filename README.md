# PDF Services for Ruby

### Originally forked from [Adobe Document Services PDF Tools SDK for Ruby](https://github.com/arpc/pdfservices-ruby-sdk)

This gem provides a Ruby wrapper for the [Adobe PDF Services API](https://developer.adobe.com/document-services/docs/overview/). It allows you to perform various PDF operations, such as extracting content from PDFs, OCR, HTML to PDF, and document generation.

## Installation

1. Add the gem to your gemfile:

```ruby
gem "adobe_pdfservices_ruby"
```

2. Run `bundle install`

## Usage Example

The `PdfServices::Client` class allows you to perform various PDF operations, such as extracting content from PDFs. The client supports real-time updates on the operation status and retrieves the resulting file upon completion. Below is an example of how to use the client to extract content from a PDF file:

```ruby
require 'adobe_pdfservices_ruby'

# Initialize the client with your credentials
client = PdfServices::Client.new('your_client_id', 'your_client_secret')

# Path to the PDF file you want to extract content from
source_pdf = 'path/to/your/pdf/file.pdf'

# Set the options for your operation
options = { extract_elements: ['text', 'tables'] }

# Perform the operation with real-time status updates
client.extract_pdf(source_pdf, options) do |status, file|
  if status == 'in progress'
    puts "Current status: #{status}"
  elsif status == 'done'
    puts "Extraction complete! The resulting file is ready for download."
    # Process or save the resulting file
    File.open('extracted_result.pdf', 'w') { |f| f.write(file) }
  else
    puts "Current status: #{status}"
  end
end

# Perform the operation and only retrieve the resulting file
file = client.extract_pdf(source_pdf, options)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Currently Supported

Work is in progress on getting the gem to support all of the operations available in the [Adobe PDF Services API](https://developer.adobe.com/document-services/docs/overview/). Below is a list of the operations and their current support status:

- ✅ Extract PDF
- ✅ OCR
  - ✅ Internal
  - ❗ EXPERIMENTAL: External
- ✅ HTML to PDF
  - ✅ Internal
  - ❗ EXPERIMENTAL: External
- ✅ Document Generation:
  - ✅ Internal
  - ❗ EXPERIMENTAL: External

### Operation parameters

The parameters for each method are listed in the [Adobe PDF Services API documentation](https://developer.adobe.com/document-services/docs/overview/). The parameters are passed to the methods
as a hash.

For most operations that rely on a file as the first parameter, this can either be the path to the file or a File object.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/benterova/adobe_pdfservices_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/benterova/adobe_pdfservices_ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Be good. [code of conduct](https://github.com/benterova/adobe_pdfservices_ruby/blob/main/CODE_OF_CONDUCT.md).
