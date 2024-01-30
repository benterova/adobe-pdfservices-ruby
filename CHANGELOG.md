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

## [0.1.3] - 2024-01-27

- Fix incorrect URLs in README
- Fix incorrect URLs in gemspec
- Add support for document generation via spike
- Fix passed blocks not being called for most operations
- Add support for html_to_pdf operation via spike
- Add support for OCR operation via spike

## [0.1.4] - 2024-01-29

- Remove require for multipart parser

## [0.1.5] - 2024-01-29

- Refactor upload_asset method to handle both file paths and file objects

## [0.1.6] - 2024-01-29

- Re-add accidentally removed initialization of @api in base operation

## [0.1.7] - 2024-01-29

- Add support for uploading assets from a string or a stream

## [0.1.8] - 2024-01-29

- Flip checks between IO and paths in upload_asset method