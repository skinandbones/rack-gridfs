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
          gridfs_request( identifier_for_path(env['PATH_INFO']) )
        end

        def identifier_for_path(path)
          @mapper.respond_to?(:call) ? @mapper.call(path) : path
        end

        def db
          @options[:db]
        end

        protected

        def gridfs_request(identifier)
          file = find_file(identifier)
          [200, headers(file), file]
        rescue Mongo::GridFileNotFound, BSON::InvalidObjectId
          [404, {'Content-Type' => 'text/plain'}, ['File not found.']]
        end

        def find_file(identifier)
          case @lookup.to_sym
          when :id   then Mongo::Grid.new(db).get(BSON::ObjectId.from_string(identifier))
          when :path then Mongo::GridFileSystem.new(db).open(identifier, "r")
          end
        end

        def headers(file)
          { "Content-Type" => file.content_type }
        end

      end
    end
  end
end