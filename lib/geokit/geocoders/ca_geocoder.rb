
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
       res = self.call_geocoder_service(url)
       return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
       xml = res.body
       logger.debug "Geocoder.ca geocoding. Address: #{address}. Result: #{xml}"
       # Parse the document.
       doc = REXML::Document.new(xml)
       address.lat = doc.elements['//latt'].text
       address.lng = doc.elements['//longt'].text
       address.success = true
       return address
     rescue
       logger.error "Caught an error during Geocoder.ca geocoding call: "+$!
       return GeoLoc.new
     end

     # Formats the request in the format acceptable by the CA geocoder.
     def self.construct_request(location)
       url = ""
       url += add_ampersand(url) + "stno=#{location.street_number}" if location.street_address
       url += add_ampersand(url) + "addresst=#{Geokit::Inflector::url_escape(location.street_name)}" if location.street_address
       url += add_ampersand(url) + "city=#{Geokit::Inflector::url_escape(location.city)}" if location.city
       url += add_ampersand(url) + "prov=#{location.state}" if location.state
       url += add_ampersand(url) + "postal=#{location.zip}" if location.zip
       url += add_ampersand(url) + "auth=#{Geokit::Geocoders::geocoder_ca}" if Geokit::Geocoders::geocoder_ca
       url += add_ampersand(url) + "geoit=xml"
       'http://geocoder.ca/?' + url
     end

     def self.add_ampersand(url)
       url && url.length > 0 ? "&" : ""
     end
   end
 end
end
