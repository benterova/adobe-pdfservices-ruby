# PDF Services for Ruby

### Originally forked from [Adobe Document Services PDF Tools SDK for Ruby](https://github.com/arpc/pdfservices-ruby-sdk)

An Adobe PDF Services Ruby SDK provides APIs for creating, combining, exporting and manipulating PDFs.

## Installation

3. Add the gem to your gemfile:

```terminal
gem "adobe_pdfservices", git: "https://github.com/benterova/adobe-pdfservices-ruby.git"
```

## Usage Example

The `PdfServices::Client` class allows you to perform various PDF operations, such as extracting content from PDFs. The client supports real-time updates on the operation status and retrieves the resulting file upon completion. Below is an example of how to use the client to extract content from a PDF file:

```ruby
require 'pdf_services'

# Initialize the client with your credentials
client = PdfServices::Client.new('your_client_id', 'your_client_secret')

# Path to the PDF file you want to extract content from
source_pdf = 'path/to/your/pdf/file.pdf'

# Set the options for your operation
options = { extract_elements: ['text', 'tables'] }

# Perform the operation with real-time status updates
client.extract_pdf(source_pdf, options) do |status, file|
  if status == 'done'
    puts "Extraction complete! The resulting file is ready for download."
    # Process or save the resulting file
    File.open('extracted_content.txt', 'w') { |f| f.write(file) }
  else
    puts "Current status: #{status}"
  end
end

# Perform the operation and only retrieve the resulting file
file = client.extract_pdf(source_pdf, options)
```

### Supported API calls:

- Document merge. See `test/pdf_services_sdk/test_document_merge.rb` for an example usage.
- OCR. See `test/pdf_services_sdk/test_ocr.rb` for an example usage.

- Html to Pdf. See `test/pdf_services_sdk/test_html_to_pdf.rb` for an example usage.
  - zip file should contain a file named `index.html` and any other referenced assets
  - index.html must contain the following line...
    `<script src='./json.js' type='text/javascript'></script>`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pdfservices-ruby-sdk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pdfservices-ruby-sdk/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pdf Services SDK for Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pdfservices-ruby-sdk/blob/main/CODE_OF_CONDUCT.md).

```

```
