# Geocoder Us geocoder implementation.  Requires the Geokit::Geocoders::GEOCODER_US variable to
# contain true or false based upon whether authentication is to occur.  Conforms to the
# interface set by the Geocoder class.
module Geokit
  module Geocoders
    class UsGeocoder < Geocoder
      config :key

      private

      def self.do_geocode(address)
        process :csv, submit_url(address)
      end

      def self.submit_url(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        query = (address_str =~ /^\d{5}(?:-\d{4})?$/ ? 'zip' : 'address') + "=#{Geokit::Inflector.url_escape(address_str)}"
        base = key ? "http://#{key}@geocoder.us/member" : 'http://geocoder.us'
        "#{base}/service/csv/geocode?#{query}"
      end

      def self.parse_csv(array)
        loc = GeoLoc.new
        if array.length == 5
          loc.lat, loc.lng, loc.city, loc.state, loc.zip = array
          loc.country_code = 'US'
          loc.success = true
        elsif array.length == 6
          loc.lat, loc.lng, loc.street_address, loc.city, loc.state, loc.zip = array
          loc.country_code = 'US'
          loc.success = true
        end
        loc
      end
    end
  end
end
