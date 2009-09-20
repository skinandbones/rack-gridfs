require 'test_helper'

class KeyTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app 
    Rack::Builder.new do
      use Rack::GridFS
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    end
  end

  context "Rack::GridFS" do
    should "run a mock request" do
      get "/"
      assert last_response.ok?
    end
  end

end

