module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is ip-api.com
    class IpApiGeocoder < BaseIpGeocoder
      private

      def self.do_geocode(ip, _=nil)
        process :json, ip
      end

      def self.submit_url(ip)
        "http://ip-api.com/json/#{ip}"
      end

      def self.parse_json(result)
        loc = new_loc
        return loc unless result['status'] == 'success'

        loc.success = true
        loc.city = result['city']
        loc.state = result['region']
        loc.state_name = result['regionName']
        loc.zip = result['zip']
        loc.lat = result['lat']
        loc.lng = result['lon']
        loc.country_code = result['countryCode']
        loc
      end
    end
  end
end
