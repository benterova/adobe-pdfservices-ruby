# frozen_string_literal: true

require 'dotenv/load'
require './lib/adobe_pdfservices_ruby'
require 'fileutils'

json = { message: 'World' }
word_file = File.join(Dir.pwd, 'test', 'fixtures', 'files', 'documentgeneration_template.docx')
client_id = ENV['ADOBE_CLIENT_ID']
client_secret = ENV['ADOBE_CLIENT_SECRET']
access_token = ENV['ADOBE_ACCESS_TOKEN']
file = nil
client = PdfServices::Client.new client_id, client_secret, access_token

options = {
  output_format: 'pdf',
  json_data_for_merge: json
}

client.document_generation(word_file, options) do |status, result|
  case status
  when 'in progress'
    puts "Status: #{status}"
  when 'done'
    puts "Status: #{status}"
    file = result
  when 'failed'
    puts "Status: #{status}"
    puts "Result: #{result}"
  else
    puts "Status: #{status}"
    puts "Result: #{result}"
  end
end

write_path = File.join Dir.pwd, 'tmp', 'documentgeneration.docx'
FileUtils.mkdir_p(File.dirname(write_path))

puts "Writing to #{write_path}"

File.open(write_path, 'w') do |f|
  f.write(file)
end
