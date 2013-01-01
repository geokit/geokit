module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is geoplugin.net
    class RipeGeocoder < Geocoder
      private

      def self.do_geocode(ip, options = {})
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        response = self.call_geocoder_service("http://stat.ripe.net/data/geoloc/data.json?resource=#{ip}")
        return response.is_a?(Net::HTTPSuccess) ? parse_json(response.body) : GeoLoc.new
      rescue
        logger.error "Caught an error during GeoPluginGeocoder geocoding call: #{$!}"
        return GeoLoc.new
      end

      def self.parse_json(json)
        json = MultiJson.load(json)
        geo = GeoLoc.new
        data = json['data']['locations'][0]

        geo.provider='RIPE'
        geo.city = data['city']
        geo.country_code = data['country']
        geo.lat = data['latitude']
        geo.lng = data['longitude']
        geo.success = (data['status_code'] == 200)
        return geo
      end
    end

  end
end
