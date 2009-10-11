require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

require 'rack/builder'
require 'rack/mock'
require 'rack/test'

gem 'mongo', '>= 0.15.1'

require 'mongo'
require 'mongo/gridfs'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rack', 'gridfs')
