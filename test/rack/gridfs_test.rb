require File.join(File.dirname(__FILE__), '..', 'test_helper')

class Rack::GridFSTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app 
    Rack::Builder.new do
      use Rack::GridFS
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    end
  end

  context "Rack::GridFS" do
    
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

