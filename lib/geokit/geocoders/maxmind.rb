module Geokit
  module Geocoders

  @@geoip_data_path = 'DEFINE_THE_PATH_TO_GeoLiteCity.dat'
  __define_accessors

    # Provides geocoding based upon an IP address.  The underlying web service is MaxMind
    class MaxmindGeocoder < Geocoder
      private

      def self.do_geocode(ip, options = {})
        maxmind(ip)
      rescue
        logger.error "Caught an error during MaxMind geocoding call: " + $!.to_s
        GeoLoc.new
      end


      def self.maxmind(ip)
        res = GeoIP.new(Geokit::Geocoders::geoip_data_path).city(ip)

        loc = GeoLoc.new(
          :provider => 'maxmind_city',
          :lat      => res.latitude,
          :lng      => res.longitude,
          :city     => res.city_name,
          :state    => res.region_name,
          :zip      => res.postal_code,
          :country_code => res.country_code3
        )

        loc.success = ( res.longitude.is_a?(Float) && res.latitude.is_a?(Float) )
        loc
      end
    end
  end
end
