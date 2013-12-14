module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is geoplugin.net
    class GeoPluginGeocoder < BaseIpGeocoder
      private

      def self.do_geocode(ip)
        return GeoLoc.new unless valid_ip?(ip)
        url = "http://www.geoplugin.net/xml.gp?ip=#{ip}"
        res = call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        parse :xml, res.body
      end

      def self.parse_xml(xml)
        geo = GeoLoc.new
        geo.provider='geoPlugin'
        geo.city = xml.elements['//geoplugin_city'].text
        geo.state = xml.elements['//geoplugin_region'].text
        geo.country_code = xml.elements['//geoplugin_countryCode'].text
        geo.lat = xml.elements['//geoplugin_latitude'].text.to_f
        geo.lng = xml.elements['//geoplugin_longitude'].text.to_f
        geo.success = !!geo.city && !geo.city.empty?
        geo
      end
    end

  end
end
