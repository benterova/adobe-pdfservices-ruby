# frozen_string_literal: true

require 'dotenv/load'
require './lib/adobe_pdfservices_ruby'
require 'fileutils'

pdf = File.join(Dir.pwd, 'test', 'fixtures', 'files', 'not_yet_extracted.pdf')

client_id = ENV['ADOBE_CLIENT_ID']
client_secret = ENV['ADOBE_CLIENT_SECRET']
access_token = ENV['ADOBE_ACCESS_TOKEN']

file = nil

client = PdfServices::Client.new client_id, client_secret, access_token

client.extract_pdf(pdf, { include_styles: true }) do |status, result|
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

write_path = File.join Dir.pwd, 'tmp', 'extracted.json'
FileUtils.mkdir_p(File.dirname(write_path))

puts "Writing to #{write_path}"

File.open(write_path, 'w') do |f|
  f.write(file)
end
