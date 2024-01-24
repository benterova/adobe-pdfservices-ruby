# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  test_file = ARGV[1]
  files = FileList['test/**/*_test.rb']
  t.test_files = test_file ? files.grep(/#{test_file}/) : files
end

require 'standard/rake'

task default: %i[test standard]
