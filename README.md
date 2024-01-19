# PDF Services for Ruby
### Originally forked from [Adobe Document Services PDF Tools SDK for Ruby](https://github.com/arpc/pdfservices-ruby-sdk)

An Adobe PDF Services Ruby SDK provides APIs for creating, combining, exporting and manipulating PDFs.

## Installation


3. Add the gem to your gemfile:
```terminal
gem "adobe_pdfservices", git: "https://github.com/benterova/adobe-pdfservices-ruby.git"
```

## Usage

In order to user this gem, you will need to register for and Adobe developer account which will result in you recieving a client ID and secret.

You can then initialize a client with the following code:
```ruby
credentials = {
  PDF_SERVICES_CLIENT_ID: 'your_client_id',
  PDF_SERVICES_CLIENT_SECRET: 'your_client_secret',
  PDF_SERVICES_ORGANIZATION_ID: 'your_organization_id',
}

client = PdfServices.new(credentials)

```
After initializing the client, you can make API calls using the client object, like:

```ruby
# Merge documents
file_to_merge_into = File.join(File.dirname(__FILE__), 'data', 'merge_into.docx')
json_data_to_merge = {message: "Hello World!"}.to_json
output_format = 'pdf'



```



### Supported API calls:

- Document merge. See `test/pdf_services_sdk/test_document_merge.rb` for an example usage.
- OCR. See `test/pdf_services_sdk/test_ocr.rb` for an example usage.

- Html to Pdf. See `test/pdf_services_sdk/test_html_to_pdf.rb` for an example usage.
  - zip file should contain a file named `index.html` and any other referenced assets
  - index.html must contain the following line...
```<script src='./json.js' type='text/javascript'></script>```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pdfservices-ruby-sdk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pdfservices-ruby-sdk/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pdf Services SDK for Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pdfservices-ruby-sdk/blob/main/CODE_OF_CONDUCT.md).
