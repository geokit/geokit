module Geokit
  module Geocoders
    # Bing geocoder implementation.  Requires the Geokit::Geocoders::bing variable to
    # contain a Bing Maps API key.  Conforms to the interface set by the Geocoder class.
    class BingGeocoder < Geocoder

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        url = submit_url(address)
        res = call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        xml = transcode_to_utf8(res.body)
        logger.debug "Bing geocoding. Address: #{address}. Result: #{xml}"
        parse :xml, xml
      end

      def self.submit_url(address)
        options = Geokit::Geocoders::bing_options
        culture = options && options[:culture]
        culture_string = culture ? "&c=#{culture}" : ''
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        "http://dev.virtualearth.net/REST/v1/Locations/#{URI.escape(address_str)}?key=#{Geokit::Geocoders::bing}#{culture_string}&o=xml"
      end

      def self.parse_xml(doc)
        return GeoLoc.new if doc.elements['//Response/StatusCode'].try(:text) != '200'
        loc = nil
        # Bing can return multiple results as //Location elements.
        # iterate through each and extract each location as a geoloc
        doc.each_element('//Location') do |l|
          extracted_geoloc = extract_location(l)
          loc.nil? ? loc = extracted_geoloc : loc.all.push(extracted_geoloc)
        end
        loc
      end

      # extracts a single geoloc from a //Location element in the bing results xml
      def self.extract_location(doc)
        loc                 = GeoLoc.new
        loc.provider        = 'bing'
        loc.lat             = doc.elements['.//Latitude'].try(:text)
        loc.lng             = doc.elements['.//Longitude'].try(:text)
        set_address_components(loc, doc)
        set_precision(loc, doc)
        set_bounds(loc, doc)
        loc.success         = true
        loc
      end

      def self.set_address_components(loc, doc)
        # Fix for Germany, where often the locality is really sublocality so fallback to AdminDistrict2
        loc.city            = doc.elements['.//AdminDistrict2'].try(:text) || doc.elements['.//Locality'].try(:text)
        loc.state           = doc.elements['.//AdminDistrict'].try(:text)
        loc.province        = doc.elements['.//AdminDistrict2'].try(:text)
        loc.full_address    = doc.elements['.//FormattedAddress'].try(:text)
        loc.zip             = doc.elements['.//PostalCode'].try(:text)
        loc.street_address  = doc.elements['.//AddressLine'].try(:text)
        loc.country         = doc.elements['.//CountryRegion'].try(:text)
      end

      def self.set_precision(loc, doc)
        if doc.elements['.//Confidence']
          loc.accuracy      = case doc.elements['.//Confidence'].text
          when 'High'    then 8
          when 'Medium'  then 5
          when 'Low'     then 2
          else             0
          end
        end

        if doc.elements['.//EntityType']
          loc.precision     = case doc.elements['.//EntityType'].text
          when 'Sovereign'      then 'country'
          when 'AdminDivision1' then 'state'
          when 'AdminDivision2' then 'state'
          when 'PopulatedPlace' then 'city'
          when 'Postcode1'      then 'zip'
          when 'Postcode2'      then 'zip'
          when 'RoadBlock'      then 'street'
          when 'Address'        then 'address'
          else                    'unkown'
          end
        end
      end

      def self.set_bounds(loc, doc)
        if suggested_bounds = doc.elements['.//BoundingBox']
          bounds = suggested_bounds.elements
          loc.suggested_bounds = Bounds.normalize(
            [bounds['.//SouthLatitude'].text, bounds['.//WestLongitude'].text],
            [bounds['.//NorthLatitude'].text, bounds['.//EastLongitude'].text])
        end
      end
    end
  end
end
