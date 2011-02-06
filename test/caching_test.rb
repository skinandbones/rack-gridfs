require 'test_helper'

class CachingTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::GridFS::Test::Methods

  context "Rack::GridFS::Endpoint::Caching" do
    setup do
      def app
        setup_app(:lookup => :path, :expires => 1800)
      end

      @text_file = load_artifact('test.txt', nil, path='text')
      @html_file = load_artifact('test.html', nil, path='html')
    end

    teardown do
      db.collection('fs.files').remove
    end

    should "set expires header" do
      get "/gridfs/#{@text_file.filename}"
      assert_cache_control "max-age=1800, public"
    end
  end
end
