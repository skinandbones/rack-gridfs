require 'mongo'
require 'timeout'
require 'active_support/core_ext'

module Rack
  
  class GridFSConnectonError < StandardError ; end
  
  class GridFS
    
    attr_reader :hostname, :port, :database, :prefix, :connection
    
    def initialize(app, options = {})
      options.reverse_merge!(
        :hostname => 'localhost', 
        :port => Mongo::Connection::DEFAULT_PORT,
        :prefix => 'gridfs'
      )

      @app      = app
      @hostname = options[:hostname]
      @port     = options[:port]
      @database = options[:database]
      @prefix   = options[:prefix]
      
      connect!
    end

    def call(env)
      @app.call(env)
    end
    
    private
    
    def connect!
      Timeout::timeout(5) do
        self.connection = Mongo::Connection.new(hostname).db(database)
      end
    rescue
      raise Rack::GridFSConnectonError, 'Unable to connect to the MongoDB server'
    end
    
  end
    
end
