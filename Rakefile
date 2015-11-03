require 'bundler/setup'
require 'rake/testtask'
require 'yard'

require File.expand_path("../lib/rack/gridfs/version", __FILE__)

Bundler::GemHelper.install_tasks

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.test_files = FileList['test/**/*_test.rb']
    test.verbose = true
    test.rcov_opts << '--exclude /gems/,/Library/,/usr/,spec,lib/tasks'
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: gem install rcov"
  end
end

YARD::Rake::YardocTask.new do |t|
  t.name = 'doc'
  t.files = ['lib/**/*.rb']
end
