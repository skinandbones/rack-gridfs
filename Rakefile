require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

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

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  require File.expand_path("../lib/rack/gridfs/version", __FILE__)

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Rack::GridFS #{Rack::GridFS::VERSION}"
  rdoc.rdoc_files.include(%w[ README* CHANGES* ])
  rdoc.rdoc_files.include('lib/**/*.rb')
end
