module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is geoplugin.net
    class RipeGeocoder < BaseIpGeocoder
      private

      def self.do_geocode(ip, options = {})
        return GeoLoc.new unless valid_ip?(ip)
        url = "http://stat.ripe.net/data/geoloc/data.json?resource=#{ip}"
        res = call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        parse_json(res.body)
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
        geo
      end
    end

  end
end
