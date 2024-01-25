# frozen_string_literal: true

require 'dotenv/load'
require './lib/adobe_pdfservices_ruby'
require 'fileutils'

pdf = File.join(Dir.pwd, 'test', 'fixtures', 'files', 'not_yet_extracted.pdf')

client_id = ENV['ADOBE_CLIENT_ID']
client_secret = ENV['ADOBE_CLIENT_SECRET']
access_token = ENV['ADOBE_ACCESS_TOKEN']

client = PdfServices::Client.new client_id, client_secret, access_token

file = client.extract_pdf(pdf, { include_styles: true })

write_path = File.join Dir.pwd, 'tmp', 'extracted.json'
FileUtils.mkdir_p(File.dirname(write_path))

puts "Writing to #{write_path}"

File.open(write_path, 'w') do |f|
  f.write(file)
end
