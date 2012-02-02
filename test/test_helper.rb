require 'test/unit'
require 'shoulda'
require 'mocha'

require 'rack/builder'
require 'rack/mock'
require 'rack/test'

require 'rack/gridfs'

class Hash
  def except(*keys)
    rejected = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    reject { |key,| rejected.include?(key) }
  end
end

module Rack
  class GridFS
    module Test
      module Methods

        def stub_mongodb_connection
          Rack::GridFS::Endpoint.any_instance.stubs(:connect!).returns(true)
        end

        def test_database_options
          { :hostname => 'localhost', :port => 27017, :database => 'test', :prefix => 'gridfs' }
        end

        def db
          @db ||= Mongo::Connection.new(test_database_options[:hostname], test_database_options[:port]).db(test_database_options[:database])
        end

        def setup_middleware(opts={})
          gridfs_opts = test_database_options.merge(opts)

          Rack::Builder.new do
            use Rack::ConditionalGet
            use Rack::GridFS, gridfs_opts
            run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
          end
        end

        def setup_endpoint(opts={})
          endpoint_opts = test_database_options.except(:prefix).merge(opts)

          Rack::Builder.new do
            use Rack::ConditionalGet
            map '/gridfs' do
              run Rack::GridFS::Endpoint.new(endpoint_opts)
            end
            map '/' do
              run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
            end
          end
        end

        def load_artifact(filename, content_type, path=nil, _id=nil)
          contents = ::File.read(::File.join(::File.dirname(__FILE__), 'artifacts', filename))
          if path
            grid = Mongo::GridFileSystem.new(db)
            file = [path, filename].join('/')
            grid.open(file, 'w') { |f| f.write contents }
            grid.open(file, 'r')
          else
            options = {:filename => filename, :content_type => content_type}
            options.merge!(:_id => _id) if _id
            Mongo::Grid.new(db).put(contents, options)
          end
        end

        def assert_cache_control(cache_control)
          assert_equal_header cache_control, "Cache-Control"
        end

        def assert_content_disposition(content_disposition)
          assert_equal_header content_disposition, "Content-Disposition"
        end

        def assert_equal_header(expected, header)
          assert_equal expected, last_response.headers[header]
        end
      end
    end
  end
end
