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
        parse :json, res.body
      end

      def self.parse_json(json)
        geo = GeoLoc.new
        data = json['data']['locations'][0]

        match = data['country'].match /([A-Z]+)(\(([A-Z]+)\))?/
        if match[3]
          geo.state = match[1]
          geo.country_code = match[3]
        else
          geo.country_code = match[1]
        end

        geo.provider='RIPE'
        geo.city = data['city']
        geo.lat = data['latitude']
        geo.lng = data['longitude']
        geo.success = (data['status_code'] == 200)
        geo
      end
    end

  end
end
