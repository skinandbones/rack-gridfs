require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

require 'rack/builder'
require 'rack/mock'
require 'rack/test'

require 'mongo'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rack', 'gridfs')
