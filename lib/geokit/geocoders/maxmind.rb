module Geokit
  module Geocoders

  @@geoip_data_path = 'DEFINE_THE_PATH_TO_GeoLiteCity.dat'
  __define_accessors

    # Provides geocoding based upon an IP address.  The underlying web service is MaxMind
    class MaxmindGeocoder < Geocoder
      private

      def self.do_geocode(ip)
        res = GeoIP.new(Geokit::Geocoders::geoip_data_path).city(ip)

        loc = new_loc
        loc.lat          = res.latitude
        loc.lng          = res.longitude
        loc.city         = res.city_name
        loc.state        = res.region_name
        loc.zip          = res.postal_code
        loc.country_code = res.country_code2

        loc.success = ( res.longitude.kind_of?(Numeric) && res.latitude.kind_of?(Numeric) )
        loc
      end
    end
  end
end
