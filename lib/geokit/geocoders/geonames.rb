module Geokit
  module Geocoders
    # Another geocoding web service
    # http://www.geonames.org
    class GeonamesGeocoder < Geocoder

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        # geonames need a space seperated search string
        address_str.gsub!(/,/, " ")
        params = "/postalCodeSearch?placename=#{Geokit::Inflector::url_escape(address_str)}&maxRows=10"

        url = if Geokit::Geocoders::geonames
          "http://ws.geonames.net#{params}&username=#{Geokit::Geocoders::geonames}"
        else
          "http://ws.geonames.org#{params}"
        end

        res = call_geocoder_service(url)

        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)

        xml=res.body
        logger.debug "Geonames geocoding. Address: #{address}. Result: #{xml}"
        parse :xml, xml
      end

      XML_MAPPINGS = {
        :city         => 'name',
        :state        => 'adminName1',
        :zip          => 'postalcode',
        :country_code => 'countryCode',
        :lat          => 'lat',
        :lng          => 'lng'
      }

      def self.parse_xml(xml)
        return GeoLoc.new unless xml.elements['geonames/totalResultsCount'].text.to_i > 0
        loc = GeoLoc.new
        loc.provider = 'genomes'
        # only take the first result
        set_mappings(loc, xml.elements['geonames/code'], XML_MAPPINGS)
        loc.success = true
        loc
      end
    end
  end
end
