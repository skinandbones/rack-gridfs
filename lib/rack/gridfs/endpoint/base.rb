module Rack
  class GridFS
    class Endpoint
      module Base

        def initialize(options = {})
          @options = {
            :hostname => 'localhost',
            :port     => Mongo::Connection::DEFAULT_PORT,
            :lookup   => :id
          }.merge(options)

          @lookup = @options[:lookup]
          @mapper = @options[:mapper]
        end

        def call(env)
          request = Rack::Request.new(env)
          id      = identifier_for_path(request.path_info)
          file    = find_file(id)

          response_for(file, request)
        rescue Mongo::GridError, BSON::InvalidObjectId
          [404, {'Content-Type' => 'text/plain'}, ['File not found.' + id]]
        rescue Mongo::GridFileNotFound
          [404, {'Content-Type' => 'text/plain'}, ['File not found.']]
        end

        def identifier_for_path(path)
          @mapper.respond_to?(:call) ? @mapper.call(path) : path
        end

        def db
          @options[:db]
        end

        protected

        def response_for(file, request)
          [ 200, headers(file), file ]
        end

        def find_file(id_or_path)
          case @lookup.to_sym
          when :id   then Mongo::Grid.new(db).get(BSON::ObjectId.from_string(id_or_path))
          when :path then Mongo::GridFileSystem.new(db).open(id_or_path, "r")
          end
        end

        def headers(file)
          { 'Content-Type' => file.content_type }
        end

      end
    end
  end
end