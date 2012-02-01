require 'rack/gridfs/endpoint/base'
require 'rack/gridfs/endpoint/caching'
require 'rack/gridfs/endpoint/connection'
require 'rack/gridfs/endpoint/disposition'

module Rack
  class GridFS
    class Endpoint
      include Base
      include Connection
      include Caching
      include Disposition
    end
  end
end
