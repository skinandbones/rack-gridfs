module Rack
  class GridFS
    class Endpoint

      module Caching
        def initialize(*)
          super
          @options[:expires] ||= false
        end

        protected

        def headers(file)
          super.merge( cache_control_header(file) )
        end

        private

        def cache_control_header(file)
          if @options[:expires]
            { "Cache-Control" => "max-age=#{@options[:expires]}, public" }
          else
            {}
          end
        end

      end

    end
  end
end
