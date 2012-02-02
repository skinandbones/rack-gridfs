module Rack
  class GridFS
    class Endpoint

      module Disposition
        def initialize(*)
          super
          @options[:disposition] ||= :inline
        end

        protected

        def headers(file)
          super.merge(content_disposition_header(file))
        end

        private

        def content_disposition_header(file)
          case @options[:disposition]
          when :inline
            { "Content-Disposition" => "inline" }
          when :attachment
            { "Content-Disposition" => "attachment; filename=#{file.filename}" }
          else
            {}
          end
        end

      end

    end
  end
end
