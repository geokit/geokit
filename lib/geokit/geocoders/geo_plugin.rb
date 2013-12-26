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

      XML_MAPPINGS = {
        :city         => 'geoplugin_city',
        :state        => 'geoplugin_region',
        :country_code => 'geoplugin_countryCode',
        :lat          => 'geoplugin_latitude',
        :lng          => 'geoplugin_longitude'
      }

      def self.parse_xml(xml)
        loc = new_loc
        set_mappings(loc, xml.elements['geoPlugin'], XML_MAPPINGS)
        loc.success = !!loc.city && !loc.city.empty?
        loc
      end
    end

  end
end
