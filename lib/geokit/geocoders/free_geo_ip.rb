module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is freegeoip.net
    class FreeGeoIpGeocoder < BaseIpGeocoder
      private

      def self.do_geocode(ip)
        return GeoLoc.new unless valid_ip?(ip)
        url = "http://freegeoip.net/xml/#{ip}"
        res = call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        parse :xml, res.body
      end

      XML_MAPPINGS = {
        :city         => 'City',
        :state        => 'RegionCode',
        :zip          => 'ZipCode',
        :country_code => 'CountryCode',
        :lat          => 'Latitude',
        :lng          => 'Longitude'
      }

      def self.parse_xml(xml)
        loc = GeoLoc.new
        loc.provider = 'freegeoip'
        set_mappings(loc, xml.elements['Response'], XML_MAPPINGS)
        loc.success = !!loc.city && !loc.city.empty?
        loc
      end
    end

  end
end
