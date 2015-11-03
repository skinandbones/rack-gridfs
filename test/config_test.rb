require 'test_helper'

class ConfigTest < Minitest::Test
  include Rack::Test::Methods
  include Rack::GridFS::Test::Methods

  context "Rack::GridFS" do
    context "on initialization" do
      MONGODB_URI = 'mongodb://bob:so-s3cur3@myhostname.mydomain:8765/mydatabase'

      setup do
        stub_mongodb_connection
        @options = {
          :hostname => 'myhostname.mydomain',
          :port => 8765,
          :database => 'mydatabase',
          :prefix => 'myprefix',
          :username => 'bob',
          :password => 'so-s3cur3',
          :mapper => lambda { |path| %r{^/files/myprefix/(.+)}.match(path)[1] }
        }
      end

      should "have a hostname option" do
        mware = Rack::GridFS::Endpoint.new(@options)
        assert_equal @options[:hostname], mware.instance_variable_get(:@hostname)
      end

      should "have a default hostname" do
        mware = Rack::GridFS::Endpoint.new(@options.except(:hostname))
        assert_equal 'localhost', mware.instance_variable_get(:@hostname)
      end

      should "have a port option" do
        mware = Rack::GridFS::Endpoint.new(@options)
        assert_equal @options[:port], mware.instance_variable_get(:@port)
      end

      should "have a default port" do
        mware = Rack::GridFS::Endpoint.new(@options.except(:port))
        assert_equal Mongo::Connection::DEFAULT_PORT, mware.instance_variable_get(:@port)
      end

      should "have a database option" do
        mware = Rack::GridFS::Endpoint.new(@options)
        assert_equal @options[:database], mware.instance_variable_get(:@database)
      end

      should "not have a default database" do
        mware = Rack::GridFS::Endpoint.new(@options.except(:database))
        assert_nil mware.instance_variable_get(:@database)
      end

      should "have a prefix option" do
        mware = Rack::GridFS.new(nil, @options)
        assert_equal mware.instance_variable_get(:@options)[:prefix], 'myprefix'
      end

      should "have a default prefix" do
        mware = Rack::GridFS.new(nil, @options.except(:prefix))
        assert_equal mware.instance_variable_get(:@options)[:prefix], 'gridfs'
      end

      should "have a normalized prefix" do
        mware = Rack::GridFS.new(nil, @options.merge({:prefix => '/myprefix'}))
        assert_equal mware.instance_variable_get(:@options)[:prefix], 'myprefix'
      end

      should "have a username option" do
        mware = Rack::GridFS::Endpoint.new(@options)
        assert_equal @options[:username], mware.instance_variable_get(:@username)
      end

      should "have a password option" do
        mware = Rack::GridFS::Endpoint.new(@options)
        assert_equal @options[:password], mware.instance_variable_get(:@password)
      end
      
      should "have an uri option" do
        mware = Rack::GridFS::Endpoint.new(:uri => MONGODB_URI)
        assert_equal MONGODB_URI, mware.instance_variable_get(:@uri)
      end

      should "not have a default username" do
        mware = Rack::GridFS::Endpoint.new(@options.except(:username))
        assert_nil mware.instance_variable_get(:@username)
      end

      should "not have a default password" do
        mware = Rack::GridFS::Endpoint.new(@options.except(:password))
        assert_nil mware.instance_variable_get(:@password)
      end

      should "have a mapper option" do
        mware = Rack::GridFS::Endpoint.new(@options)
        assert_equal @options[:mapper], mware.instance_variable_get(:@mapper)
      end

      should "have a default mapper" do
        mware = Rack::GridFS::Endpoint.new(@options.except(:mapper))
        refute_nil mware.instance_variable_get(:@options)[:mapper]
      end

      should "not mutate caller's option values" do
        options = @options.merge({:prefix => '/slashed'})
        Rack::GridFS.new(nil, options)
        assert_equal options[:prefix], '/slashed'
      end

      should "connect to the MongoDB server by options" do
        Rack::GridFS::Endpoint.any_instance.expects(:connect!).returns(true).once
        Rack::GridFS::Endpoint.new(@options).db
      end
      
      should "connect to the MongoDB server by uri" do
        Rack::GridFS::Endpoint.any_instance.expects(:connect!).returns(true).once
        Rack::GridFS::Endpoint.new(:uri => MONGODB_URI).db
      end

    end
  end

end

