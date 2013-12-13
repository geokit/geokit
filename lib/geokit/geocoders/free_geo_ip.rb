module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is freegeoip.net
    class FreeGeoIpGeocoder < BaseIpGeocoder
      private

      def self.do_geocode(ip, options = {})
        return GeoLoc.new unless valid_ip?(ip)
        url = "http://freegeoip.net/xml/#{ip}"
        response = call_geocoder_service(url)
        response.is_a?(Net::HTTPSuccess) ? parse_xml(response.body) : GeoLoc.new
      end

      def self.parse_xml(xml)
        xml = REXML::Document.new(xml)
        geo = GeoLoc.new
        geo.provider='freegeoip'
        geo.city = xml.elements['//City'].text
        geo.state = xml.elements['//RegionCode'].text
        geo.zip = xml.elements['//ZipCode'].text
        geo.country_code = xml.elements['//CountryCode'].text
        geo.lat = xml.elements['//Latitude'].text.to_f
        geo.lng = xml.elements['//Longitude'].text.to_f
        geo.success = !!geo.city && !geo.city.empty?
        geo
      end
    end

  end
end
