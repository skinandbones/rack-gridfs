require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name              = "rack-gridfs"
    gem.summary           = "Rack middleware for creating HTTP endpoints for files stored in MongoDB's GridFS"
    gem.email             = "blake@coin-operated.net"
    gem.homepage          = "http://github.com/skinandbones/rack-gridfs"
    gem.authors           = ["Blake Carlson"]
    gem.rubyforge_project = "rack-gridfs"
    
    gem.add_dependency('rack')
    gem.add_dependency('activesupport')
    gem.add_dependency('mongo', '0.18.2')
    
    gem.add_development_dependency('mocha', '0.9.4')
    gem.add_development_dependency('rack-test')
    gem.add_development_dependency('thoughtbot-shoulda')
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

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
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Rack::GridFS #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
