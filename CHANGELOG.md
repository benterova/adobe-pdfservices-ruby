## [Unreleased]

## [0.1.0] - 2022-08-25

- Initial release

## [0.1.1] - 2024-01-18

- Refactor for DRYness and use modern Ruby syntax
- Add support for PDF extraction
- Change usage to use a single client object
- EXPERIMENTAL: Add support for internal and external operations (OCR, htmltopdf, documentgeneration)
- Update tests
- Update README

## [0.1.2] - 2024-01-25

- Update URL's in gemspec
- Fix misnamed parameters in extract_pdf operation
- Remove multiple authorization headers for pre-signed URL's
- Remove push_host from gemspec
- Allow client to be initialized with no secret_key if there's an access_token provided (useful for development)
- Asset delete request is properly formed
- Use MimeMagic to determine content-type of files
