module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address. The underlying web service is
    # ipstack, old freegeoip.net
    class IpstackGeocoder < BaseIpGeocoder
      config :api_key

      private

      def self.do_geocode(ip, _options = nil)
        process :json, ip
      end

      def self.submit_url(ip)
        "http://api.ipstack.com/#{ip}?access_key=#{api_key}"
      end

      def self.parse_json(result)
        loc = new_loc
        return loc if result['success'] == false

        loc.city = result['city']
        loc.state_code = result['region_code']
        loc.state_name = result['region_name']
        loc.zip = result['zip']
        loc.lat = result['latitude']
        loc.lng = result['longitude']
        loc.country_code = result['country_code']
        loc.country = result['country_name']
        loc.success = !loc.country_code.nil?

        loc
      end
    end
  end
end
