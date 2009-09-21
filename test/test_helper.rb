require 'rubygems'
require 'test/unit'
require 'shoulda'

gem 'mocha', '0.9.4'
require 'mocha'

require 'rack/builder'
require 'rack/mock'
require 'rack/test'

require 'mongo'
require 'mongo/gridfs'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rack', 'gridfs')
