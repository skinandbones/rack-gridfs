require 'timeout'
require 'mongo'

module Rack
  class GridFSConnectionError < StandardError ; end

  class GridFS
    autoload :Endpoint, "rack/gridfs/endpoint"

    def initialize(app, options={})
      @app     = app
      @options = normalize_options(options)
    end

    def call(env)
      if env['PATH_INFO'] =~ %r{^/#{@options[:prefix]}/*}
        endpoint.call(env)
      else
        @app.call(env)
      end
    end

    private

    def normalize_options(options)
      options.tap do |opts|
        opts[:prefix] ||= "gridfs"
        opts[:prefix].gsub!(/^\//, '')
        opts[:mapper] ||= lambda { |p| p[%r{^/#{options[:prefix]}/(.+)}, 1] }
      end
    end

    def endpoint
      @endpoint ||= Endpoint.new(@options)
    end
  end
end
