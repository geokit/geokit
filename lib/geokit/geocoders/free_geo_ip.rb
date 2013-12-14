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

      def self.parse_xml(xml)
        loc = GeoLoc.new
        loc.provider='freegeoip'
        loc.city = xml.elements['//City'].text
        loc.state = xml.elements['//RegionCode'].text
        loc.zip = xml.elements['//ZipCode'].text
        loc.country_code = xml.elements['//CountryCode'].text
        loc.lat = xml.elements['//Latitude'].text.to_f
        loc.lng = xml.elements['//Longitude'].text.to_f
        loc.success = !!loc.city && !loc.city.empty?
        loc
      end
    end

  end
end
