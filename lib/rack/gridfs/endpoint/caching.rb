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
          super.merge(
            'Last-Modified' => file.upload_date.httpdate,
            'Etag'          => file.files_id.to_s
          ).merge(cache_control_header)
        end

        private

        def cache_control_header
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
