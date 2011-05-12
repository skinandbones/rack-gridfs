require 'rack/gridfs/endpoint/base'
require 'rack/gridfs/endpoint/caching'
require 'rack/gridfs/endpoint/connection'

module Rack
  class GridFS
    class Endpoint
      include Base
      include Connection
      include Caching
    end
  end
end
