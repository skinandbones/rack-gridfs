require 'mongo'
require 'mime/types'
require 'cgi'

module Rack
  class GridFSConnectionError < StandardError ; end

  # Rack middleware that will serve GridFS files from a specified path prefix.
  # By default the prefix is stripped from the path before file lookup in
  # GridFS occurs.
  #
  # For example:
  #
  #     "/gridfs/filename.png" -> "filename.png"
  #
  # If you are using Rails you can mount the endpoint directly.
  #
  # For example (in config/routes.rb):
  #
  #     mount Rack::GridFS::Endpoint, :at => "gridfs"

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

    # TODO: doc explanation/example of custom mapper
    def normalize_options(options)
      options.tap do |opts|
        opts[:prefix] ||= "gridfs"
        opts[:prefix].gsub!(/^\//, '')
        opts[:mapper] ||= lambda { |path| %r!^/#{options[:prefix]}/(.+)!.match(path)[1] }
      end
    end

    def endpoint
      @endpoint ||= Endpoint.new(@options)
    end
  end
end
