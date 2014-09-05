module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is geoplugin.net
    class GeoPluginGeocoder < BaseIpGeocoder
      private

      def self.do_geocode(ip)
        process :xml, ip
      end

      def self.submit_url(ip)
        "http://www.geoplugin.net/xml.gp?ip=#{ip}"
      end

      XML_MAPPINGS = {
        city:         'geoplugin_city',
        state:        'geoplugin_region',
        country_code: 'geoplugin_countryCode',
        lat:          'geoplugin_latitude',
        lng:          'geoplugin_longitude'
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
