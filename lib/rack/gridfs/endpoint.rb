module Rack
  class GridFS
    class Endpoint

      def initialize(options = {})
        options = {
          :hostname => 'localhost',
          :port     => Mongo::Connection::DEFAULT_PORT,
          :lookup   => :id
        }.merge(options)

        @lookup = options[:lookup]
        @db     = options[:db]
        @mapper = options[:mapper]

        @hostname, @port, @database, @username, @password =
          options.values_at(:hostname, :port, :database, :username, :password)
      end

      def call(env)
        gridfs_request( identifier_for_path(env['PATH_INFO']) )
      end

      def identifier_for_path(path)
        @mapper.respond_to?(:call) ? @mapper.call(path) : path
      end

      def db
        @db || connect!
      end

      private

      def connect!
        Timeout::timeout(5) do
          @db = Mongo::Connection.new(@hostname, @port).db(@database)
          @db.authenticate(@username, @password) if @username
        end

        return @db
      rescue Exception => e
        raise Rack::GridFSConnectionError, "Unable to connect to the MongoDB server (#{e.to_s})"
      end

      def gridfs_request(identifier)
        file = find_file(identifier)
        [200, {'Content-Type' => file.content_type}, file]
      rescue Mongo::GridFileNotFound, BSON::InvalidObjectId
        [404, {'Content-Type' => 'text/plain'}, ['File not found.']]
      end

      def find_file(identifier)
        case @lookup.to_sym
        when :id   then Mongo::Grid.new(db).get(BSON::ObjectId.from_string(identifier))
        when :path then Mongo::GridFileSystem.new(db).open(identifier, "r")
        end
      end

    end
  end
end
