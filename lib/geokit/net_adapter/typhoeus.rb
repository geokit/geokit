module Geokit
  module NetAdapter
    class Typhoeus
      def self.do_get(url)
        ::Typhoeus.get(url.to_s)
      end

      def self.success?(response)
        response.success?
      end
    end
  end
end
