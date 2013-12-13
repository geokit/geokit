
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

     private

     # Template method which does the geocode lookup.
     def self.do_geocode(address, options = {})
       raise ArgumentError('Geocoder.ca requires a GeoLoc argument') unless address.is_a?(GeoLoc)
       url = construct_request(address)
       res = call_geocoder_service(url)
       return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
       xml = res.body
       logger.debug "Geocoder.ca geocoding. Address: #{address}. Result: #{xml}"
       parse :xml, xml, address
    end

    def self.parse_xml(doc, address)
       address.lat = doc.elements['//latt'].text
       address.lng = doc.elements['//longt'].text
       address.success = true
       address
     end

     # Formats the request in the format acceptable by the CA geocoder.
     def self.construct_request(location)
       args = []
       args << "stno=#{location.street_number}" if location.street_address
       args << "addresst=#{Geokit::Inflector::url_escape(location.street_name)}" if location.street_address
       args << "city=#{Geokit::Inflector::url_escape(location.city)}" if location.city
       args << "prov=#{location.state}" if location.state
       args << "postal=#{location.zip}" if location.zip
       args << "auth=#{Geokit::Geocoders::geocoder_ca}" if Geokit::Geocoders::geocoder_ca
       args << "geoit=xml"
       'http://geocoder.ca/?' + args.join('&')
     end
   end
 end
end
