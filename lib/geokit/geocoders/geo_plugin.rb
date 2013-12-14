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
        loc = GeoLoc.new
        loc.provider='geoPlugin'
        loc.city = xml.elements['//geoplugin_city'].text
        loc.state = xml.elements['//geoplugin_region'].text
        loc.country_code = xml.elements['//geoplugin_countryCode'].text
        loc.lat = xml.elements['//geoplugin_latitude'].text.to_f
        loc.lng = xml.elements['//geoplugin_longitude'].text.to_f
        loc.success = !!loc.city && !loc.city.empty?
        loc
      end
    end

  end
end
