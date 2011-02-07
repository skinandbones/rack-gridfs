require 'test_helper'

class ExceptionsTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::GridFS::Test::Methods

  context "Rack::GridFS Exceptions" do
    setup do
      def app
        setup_app(:lookup => :path)
      end

      @text_file = load_artifact('test.txt', nil)
      @html_file = load_artifact('test.html', nil)
    end

    teardown do
      db.collection('fs.files').remove
    end

    should "return a 500 if an error occurs" do
      Rack::GridFS::Endpoint.any_instance.stubs(:find_file).raises(Mongo::GridError)

      get "/gridfs/anything"
      assert_equal 500, last_response.status
    end

    should "retry on connection failure" do
      gridfile = Mongo::GridFileSystem.new(db).open("test.txt", "r")
      Rack::GridFS::Endpoint.any_instance.stubs(:find_file).raises(Mongo::ConnectionFailure).then.returns(gridfile)

      get "/gridfs/test.txt"
      assert last_response.ok?
    end
  end
end
