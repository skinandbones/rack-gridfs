require 'rubygems'
require 'rake'

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  # test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Rack::GridFS 0.0.1"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
