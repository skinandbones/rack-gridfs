require 'test_helper'

class DispositionTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::GridFS::Test::Methods

  context "Rack::GridFS::Endpoint::Disposition" do
    context "attachment" do
      setup do
        def app
          setup_endpoint(:lookup => :path, :disposition => :attachment)
        end

        @text_file = load_artifact('test.txt', nil, path='text')
      end

      teardown do
        db.collection('fs.files').remove
      end

      should "set content disposition with filename" do
        get "/gridfs/#{@text_file.filename}"
        assert_content_disposition("attachment; filename=#{@text_file.filename}")
      end
    end

    context "inline" do
      setup do
        def app
          setup_endpoint(:lookup => :path, :disposition => :inline)
        end

        @text_file = load_artifact('test.txt', nil, path='text')
      end

      teardown do
        db.collection('fs.files').remove
      end

      should "set content disposition header to inline" do
        get "/gridfs/#{@text_file.filename}"
        assert_content_disposition("inline")
      end
    end
  end
end
