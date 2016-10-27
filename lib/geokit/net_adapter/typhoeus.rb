module Geokit
  module NetAdapter
    class Typhoeus
      def self.do_get(url)
        Geokit::Geocoders.useragent ? headers = {'User-Agent' => Geokit::Geocoders.useragent} : headers = {}
        ::Typhoeus.get(url.to_s, :headers => headers)
      end

      def self.success?(response)
        response.success?
      end
    end
  end
end
