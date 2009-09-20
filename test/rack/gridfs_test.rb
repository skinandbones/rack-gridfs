require File.join(File.dirname(__FILE__), '..', 'test_helper')

class Rack::GridFSTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def options_for_gridfs
    { :hostname => 'myhostname.mydomain', :port => 8765, :database => 'mydatabase', :prefix => 'myprefix' }
  end
  
  def app 
    Rack::Builder.new do
      use Rack::GridFS
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    end
  end

  context "Rack::GridFS" do

    setup do
      Rack::GridFS.any_instance.stubs(:connect!).returns(true)
    end
    
    context "on initialization" do

      should "have a hostname option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal options_for_gridfs[:hostname], mware.hostname
      end

      should "have a default hostname" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:hostname))
        assert_equal 'localhost', mware.hostname
      end

      should "have a port option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal options_for_gridfs[:port], mware.port
      end

      should "have a default port" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:port))
        assert_equal Mongo::Connection::DEFAULT_PORT, mware.port
      end

      should "have a database option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal options_for_gridfs[:database], mware.database
      end

      should "not have a default database" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:database))
        assert_nil mware.database
      end

      should "have a prefix option" do
        mware = Rack::GridFS.new(nil, options_for_gridfs)
        assert_equal mware.prefix, options_for_gridfs[:prefix]
      end
      
      should "have a default prefix" do
        mware = Rack::GridFS.new(nil, options_for_gridfs.except(:prefix))
        assert_equal mware.prefix, 'gridfs'
      end

      should "connect to the MongoDB server" do
        Rack::GridFS.any_instance.expects(:connect!).returns(true).once
        Rack::GridFS.new(nil, options_for_gridfs)
      end

    end

    context "experimenting with mock requests" do
      should "run a mock request" do
        get '/'
        assert last_response.ok?
      end

      should "run an old school mock request" do
        app = Rack::Builder.new do
          use Rack::GridFS
          run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
        end

        response = Rack::MockRequest.new(app).get('/')
        assert response.ok?
      end
    end

  end

end

