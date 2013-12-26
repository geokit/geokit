module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is MaxMind
    class MaxmindGeocoder < Geocoder
      config :geoip_data_path # path to GeoLiteCity.dat

      private

      def self.do_geocode(ip)
        res = GeoIP.new(geoip_data_path).city(ip)

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
