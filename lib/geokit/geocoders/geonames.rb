module Geokit
  module Geocoders
    # Another geocoding web service
    # http://www.geonames.org
    class GeonamesGeocoder < Geocoder
      config :key

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        process :xml, submit_url(address)
      end

      def self.submit_url(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        # geonames need a space seperated search string
        address_str.gsub!(/,/, " ")
        params = "/postalCodeSearch?placename=#{Geokit::Inflector::url_escape(address_str)}&maxRows=10"

        if key
          "http://ws.geonames.net#{params}&username=#{key}"
        else
          "http://ws.geonames.org#{params}"
        end
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
        loc = new_loc
        # only take the first result
        set_mappings(loc, xml.elements['geonames/code'], XML_MAPPINGS)
        loc.success = true
        loc
      end
    end
  end
end
