module Geokit
  module NetAdapter
    class Typhoeus
      def self.do_get(url)
        headers = Geokit::Geocoders.useragent ? {'User-Agent' => Geokit::Geocoders.useragent} : {}
        ::Typhoeus.get(url.to_s, :headers => headers)
      end

      def self.success?(response)
        response.success?
      end
    end
  end
end
