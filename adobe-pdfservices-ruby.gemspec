# frozen_string_literal: true

require_relative 'lib/pdfservices/version'

Gem::Specification.new do |spec|
  spec.name = 'adobe-pdfservices-ruby'
  spec.version = PdfServices::VERSION
  spec.authors = ['Jimmy Bosse', 'Ben Terova']
  spec.email = ['jimmy.bosse@ankura.com', 'ben@benterova.com']

  spec.summary = 'Adobe PDF Services Ruby'
  spec.description = 'An Adobe PDF Services Ruby SDK provides APIs for creating, combining, exporting and manipulating PDFs.'
  spec.homepage = 'https://github.com/benterova/adobe-pdfservices-ruby/blob/main/README.md'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.2'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/benterova/adobe-pdfservices-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/benterova/adobe-pdfservices-ruby/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'faraday', '~> 2.9'
  spec.add_dependency 'json', '~> 2.6'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
