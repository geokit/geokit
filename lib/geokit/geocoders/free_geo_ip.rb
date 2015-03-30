module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is freegeoip.net
    class FreeGeoIpGeocoder < BaseIpGeocoder
      private

      def self.do_geocode(ip)
        process :xml, ip
      end

      def self.submit_url(ip)
        "http://freegeoip.net/xml/#{ip}"
      end

      XML_MAPPINGS = {
        city:         'City',
        state:        'RegionCode',
        zip:          'ZipCode',
        country_code: 'CountryCode',
        lat:          'Latitude',
        lng:          'Longitude'
      }

      def self.parse_xml(xml)
        loc = new_loc
        set_mappings(loc, xml.elements['Response'], XML_MAPPINGS)
        loc.success = !!loc.city && !loc.city.empty?
        loc
      end
    end
  end
end
