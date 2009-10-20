require 'timeout'
require 'mongo'
require 'mongo/gridfs'
require 'active_support/core_ext'

module Rack
  
  class GridFSConnectionError < StandardError ; end
  
  class GridFS

    attr_reader :hostname, :port, :database, :prefix, :connection
    
    def initialize(app, options = {})
      options.reverse_merge!(
        :hostname => 'localhost', 
        :port => Mongo::Connection::DEFAULT_PORT,
        :prefix => 'gridfs'
      )

      @app        = app
      @hostname   = options[:hostname]
      @port       = options[:port]
      @database   = options[:database]
      @prefix     = options[:prefix]
      @connection = nil

      connect!
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.path_info =~ /^\/#{prefix}\/(.+)$/
        gridfs_request($1)
      else
        @app.call(env)
      end
    end

    def not_found
      [404, {'Content-Type' => 'text/plain'}, ['File not found.']]
    end

    def gridfs_request(key)
      if ::GridFS::GridStore.exist?(connection, key)
        ::GridFS::GridStore.open(connection, key, 'r') do |file|
          [200, {'Content-Type' => file.content_type}, [file.read]]
        end
      else
        not_found
      end
    end
    
    private
    
    def connect!
      Timeout::timeout(5) do
        @connection = Mongo::Connection.new(hostname).db(database)
      end
    rescue Exception => e
      raise Rack::GridFSConnectionError, "Unable to connect to the MongoDB server (#{e.to_s})"
    end
    
  end
    
end
