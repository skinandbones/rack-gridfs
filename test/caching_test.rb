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

    should "work for small images" do
      image_id = load_artifact('3wolfmoon.jpg', 'image/jpeg')
      gridfile = Mongo::Grid.new(db).get(image_id)
      get "/gridfs/3wolfmoon.jpg"
      assert last_response.ok?
      assert_equal 'image/jpeg', last_response.content_type
      assert_equal gridfile.upload_date.httpdate, last_response.headers["Last-Modified"]
      assert_equal gridfile.files_id.to_s, last_response.headers["Etag"]
    end

    should "return 304 when Etag matches" do
      image_id = load_artifact('3wolfmoon.jpg', 'image/jpeg')
      gridfile = Mongo::Grid.new(db).get(image_id)
      get "/gridfs/3wolfmoon.jpg", nil, {'HTTP_IF_NONE_MATCH' => gridfile.files_id.to_s}
      assert_equal 304, last_response.status
    end

    should "return 304 when Last-Modified matches" do
      image_id = load_artifact('3wolfmoon.jpg', 'image/jpeg')
      gridfile = Mongo::Grid.new(db).get(image_id)
      get "/gridfs/3wolfmoon.jpg", nil, {'HTTP_IF_MODIFIED_SINCE' => gridfile.upload_date.httpdate}
      assert_equal 304, last_response.status
      assert_equal gridfile.files_id.to_s, last_response.headers['Etag']
    end

  end
end
