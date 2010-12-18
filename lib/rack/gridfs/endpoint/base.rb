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
          gridfs_request( identifier_for_path(env['PATH_INFO']), request )
        end

        def identifier_for_path(path)
          @mapper.respond_to?(:call) ? @mapper.call(path) : path
        end

        def db
          @options[:db]
        end

        protected

        def gridfs_request(id, request)
          grid = Mongo::GridFileSystem.new(db)
          file = grid.open(id, 'r')
          if request.env['If-None-Match'] == file.files_id.to_s || request.env['If-Modified-Since'] == file.upload_date.httpdate
            [304, {'Content-Type' => 'text/plain', 'Etag' => file.files_id.to_s}, ['Not modified']]
          else
            [200, headers(file), [file.read]]
          end
        rescue Mongo::GridError, BSON::InvalidObjectId
          [404, {'Content-Type' => 'text/plain'}, ['File not found.' + id]]
        rescue Mongo::GridFileNotFound
          [404, {'Content-Type' => 'text/plain'}, ['File not found.']]
        end

        def find_file(identifier)
          case @lookup.to_sym
          when :id   then Mongo::Grid.new(db).get(BSON::ObjectId.from_string(identifier))
          when :path then Mongo::GridFileSystem.new(db).open(identifier, "r")
          end
        end

        def headers(file)
          {'Content-Type' => file.content_type, 'Last-Modified' => file.upload_date.httpdate, 'Etag' => file.files_id.to_s}
        end

      end
    end
  end
end