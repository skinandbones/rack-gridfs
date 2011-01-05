# -*- encoding: utf-8 -*-
require File.expand_path("../lib/rack/gridfs", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-gridfs"
  s.version     = Rack::GridFS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Blake Carlson"]
  s.email       = ['blake@coin-operated.net']
  s.homepage    = "http://github.com/skinandbones/rack-gridfs"
  s.summary     = "Serve MongoDB GridFS files from Rack"
  s.description = "Rack middleware for creating HTTP endpoints for files stored in MongoDB's GridFS"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "rack-gridfs"

  s.add_dependency('rack')
  s.add_dependency('mongo', '~> 1.1.5')

  s.add_development_dependency('bundler', '>= 1.0.0')
  s.add_development_dependency('mocha', '0.9.4')
  s.add_development_dependency('rack-test')
  s.add_development_dependency('shoulda')

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.rdoc Rakefile)
  s.require_path = 'lib'

  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
end

