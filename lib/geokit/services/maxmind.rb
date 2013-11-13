require "geoip"

module Geokit
  module Geocoders

  @@geoip_data_path = File.expand_path(File.join(File.dirname(__FILE__),'../../..','data','GeoLiteCity.dat')) 
  __define_accessors

    # Provides geocoding based upon an IP address.  The underlying web service is MaxMind
    class MaxmindGeocoder < Geocoder
      private

      def self.do_geocode(ip, options = {})
        # return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        return maxmind(ip)
      rescue
        logger.error "Caught an error during MaxMind geocoding call: " + $!.to_s
        return GeoLoc.new
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

        # loc.success = res.city_name && res.city_name != ''
        loc.success = (res.longitude > 0 && res.latitude > 0)
        return loc
      end
    end
  end
end
