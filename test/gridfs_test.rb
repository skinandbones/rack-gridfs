# encoding: utf-8

require 'test_helper'
require 'pp'

class Rack::GridFSTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::GridFS::Test::Methods

  context "Rack::GridFS" do
    setup do
      def app; setup_middleware end
    end

    should "load artifacts" do
      image_id = load_artifact('3wolfmoon.jpg', 'image/jpeg')

      file1 = Mongo::Grid.new(db).get(image_id)
      file2 = Mongo::GridFileSystem.new(db).open('3wolfmoon.jpg', "r")
      file3 = Mongo::Grid.new(db).get(BSON::ObjectId.from_string(image_id.to_s))

      assert_equal file1.filename, file2.filename
      assert_equal file2.filename, file3.filename
    end

    should "delegate requests with a non-matching prefix" do
      %w( / /posts /posts/1 /posts/1/comments ).each do |path|
        get path
        assert last_response.ok?
        assert 'Hello, World!', last_response.body
      end
    end

    context "for lookup by ObjectId" do
      setup do
        @text_id = load_artifact('test.txt', 'text/plain')
        @html_id = load_artifact('test.html', 'text/html')
      end

      teardown do
        db.collection('fs.files').remove
      end

      should "return TXT files stored in GridFS" do
        get "/gridfs/#{@text_id}"
        assert_equal "Lorem ipsum dolor sit amet.", last_response.body
      end

      should "return the proper content type for TXT files" do
        get "/gridfs/#{@text_id}"
        assert_equal 'text/plain', last_response.content_type
      end

      should "return HTML files stored in GridFS" do
        get "/gridfs/#{@html_id}"
        assert_match /html.*?body.*Test/m, last_response.body
      end

      should "return the proper content type for HTML files" do
        get "/gridfs/#{@html_id}"
        assert_equal 'text/html', last_response.content_type
      end

      should "return a not found for a unknown path" do
        get '/gridfs/unknown'
        assert last_response.not_found?
      end

    end

    context "for lookup by filename" do
      setup do
        def app; setup_middleware(:lookup => :path) end
        @text_file = load_artifact('test.txt', nil, path='text')
        @html_file = load_artifact('test.html', nil, path='html')
      end

      teardown do
        db.collection('fs.files').remove
      end

      should "return TXT files stored in GridFS" do
        get "/gridfs/#{@text_file.filename}"
        assert_equal "Lorem ipsum dolor sit amet.", last_response.body
      end

      should "return the proper content type for TXT files" do
        get "/gridfs/#{@text_file.filename}"
        assert_equal 'text/plain', last_response.content_type
      end

      should "return HTML files stored in GridFS" do
        get "/gridfs/#{@html_file.filename}"
        assert_match /html.*?body.*Test/m, last_response.body
      end

      should "return the proper content type for HTML files" do
        get "/gridfs/#{@html_file.filename}"
        assert_equal 'text/html', last_response.content_type
      end

      should "return a not found for a unknown path" do
        get '/gridfs/unknown'
        assert last_response.not_found?
      end

      should "work for small images" do
        image_id = load_artifact('3wolfmoon.jpg', nil, 'images')
        get "/gridfs/#{image_id.filename}"
        assert last_response.ok?
        assert_equal 'image/jpeg', last_response.content_type
      end
    end

  end

  context "Rack::GridFS::Endpoint" do
    context "for lookup by ObjectId" do
      setup do
        def app; setup_endpoint end
        @text_id = load_artifact('test.txt', 'text/plain')
      end

      teardown do
        db.collection('fs.files').remove
      end

      should "return TXT files stored in GridFS" do
        get "/gridfs/#{@text_id}"
        assert_equal "Lorem ipsum dolor sit amet.", last_response.body
      end

      should "return a not found for a unknown object" do
        get '/gridfs/unknown'
        assert last_response.not_found?
      end

      should "return the proper content type for TXT files" do
        get "/gridfs/#{@text_id}"
        assert_equal 'text/plain', last_response.content_type
      end
    end

    context "for lookup by filename" do
      setup do
        def app; setup_endpoint(:lookup => :path) end
        @text_file = load_artifact('test.txt', nil, path='text')
      end

      teardown do
        db.collection('fs.files').remove
      end

      should "return TXT files stored in GridFS" do
        get "/gridfs/#{@text_file.filename}"
        assert_equal "Lorem ipsum dolor sit amet.", last_response.body
      end

      should "return the proper content type for TXT files" do
        get "/gridfs/#{@text_file.filename}"
        assert_equal 'text/plain', last_response.content_type
      end

      should "return TXT with non-ascii filename files stored in GridFS" do
        @rus_text_file = load_artifact('тест.txt', nil, path='text')
        get "/gridfs/#{CGI::escape(@rus_text_file.filename)}"
        assert_equal "Lorem ipsum dolor sit amet.", last_response.body
      end

      should "return a not found for a unknown path" do
        get '/gridfs/unknown'
        assert last_response.not_found?
      end
    end
  end

end

