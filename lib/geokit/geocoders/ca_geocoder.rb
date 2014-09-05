
# Geocoder CA geocoder implementation.  Requires the Geokit::Geocoders::GEOCODER_CA variable to
# contain true or false based upon whether authentication is to occur.  Conforms to the
# interface set by the Geocoder class.
#
# Returns a response like:
# <?xml version="1.0" encoding="UTF-8" ?>
# <geodata>
#   <latt>49.243086</latt>
#   <longt>-123.153684</longt>
# </geodata>
module Geokit
  module Geocoders
    class CaGeocoder < Geocoder
      config :key

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(loc)
        raise ArgumentError('Geocoder.ca requires a GeoLoc argument') unless loc.is_a?(GeoLoc)
        process :xml, submit_url(loc), loc
      end

      def self.parse_xml(xml, loc)
        loc.lat = xml.elements['//latt'].text
        loc.lng = xml.elements['//longt'].text
        loc.success = true
        loc
      end

      # Formats the request in the format acceptable by the CA geocoder.
      def self.submit_url(loc)
        args = []
        args << "stno=#{loc.street_number}" if loc.street_address
        args << "addresst=#{Geokit::Inflector.url_escape(loc.street_name)}" if loc.street_address
        args << "city=#{Geokit::Inflector.url_escape(loc.city)}" if loc.city
        args << "prov=#{loc.state}" if loc.state
        args << "postal=#{loc.zip}" if loc.zip
        args << "auth=#{key}" if key
        args << 'geoit=xml'
        'http://geocoder.ca/?' + args.join('&')
      end
    end
  end
end
