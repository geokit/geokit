module Geokit
  module Geocoders
    # Bing geocoder implementation.  Requires the Geokit::Geocoders::bing variable to
    # contain a Bing Maps API key.  Conforms to the interface set by the Geocoder class.
    class BingGeocoder < Geocoder
      config :key, :options
      self.secure = true

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        url = submit_url(address)
        res = call_geocoder_service(url)
        return GeoLoc.new unless net_adapter.success?(res)
        xml = transcode_to_utf8(res.body)
        parse :xml, xml
      end

      def self.submit_url(address)
        culture = options && options[:culture]
        culture_string = culture ? "&c=#{culture}" : ''
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        "#{protocol}://dev.virtualearth.net/REST/v1/Locations/#{URI.escape(address_str)}?key=#{key}#{culture_string}&o=xml"
      end

      def self.parse_xml(xml)
        return GeoLoc.new if xml.elements['//Response/StatusCode'].try(:text) != '200'
        loc = nil
        # Bing can return multiple results as //Location elements.
        # iterate through each and extract each location as a geoloc
        xml.each_element('//Location') do |l|
          extracted_geoloc = extract_location(l)
          loc.nil? ? loc = extracted_geoloc : loc.all.push(extracted_geoloc)
        end
        loc
      end

      # extracts a single geoloc from a //Location element in the bing results xml
      def self.extract_location(xml)
        loc                 = new_loc
        set_address_components(loc, xml)
        set_precision(loc, xml)
        set_bounds(loc, xml)
        loc.success         = true
        loc
      end

      XML_MAPPINGS = {
        street_address: 'Address/AddressLine',
        full_address:   'Address/FormattedAddress',
        city:           'Address/Locality',
        state:          'Address/AdminDistrict',
        province:       'Address/AdminDistrict2',
        zip:            'Address/PostalCode',
        country:        'Address/CountryRegion',
        lat:            'Point/Latitude',
        lng:            'Point/Longitude'
      }

      def self.set_address_components(loc, xml)
        set_mappings(loc, xml, XML_MAPPINGS)
      end

      ACCURACY_MAP = {
        'High'   => 8,
        'Medium' => 5,
        'Low'    => 2
      }

      PRECISION_MAP = {
        'Sovereign'      => 'country',
        'CountryRegion'  => 'country',
        'AdminDivision1' => 'state',
        'AdminDivision2' => 'state',
        'PopulatedPlace' => 'city',
        'Postcode1'      => 'zip',
        'Postcode2'      => 'zip',
        'RoadBlock'      => 'street',
        'Address'        => 'address'
      }

      def self.set_precision(loc, xml)
        if xml.elements['.//Confidence']
          loc.accuracy = ACCURACY_MAP[xml.elements['.//Confidence'].text] || 0
        end

        if xml.elements['.//EntityType']
          loc.precision = PRECISION_MAP[xml.elements['.//EntityType'].text] || 'unknown'
        end
      end

      def self.set_bounds(loc, xml)
        if suggested_bounds = xml.elements['.//BoundingBox']
          bounds = suggested_bounds.elements
          loc.suggested_bounds = Bounds.normalize(
            [bounds['.//SouthLatitude'].text, bounds['.//WestLongitude'].text],
            [bounds['.//NorthLatitude'].text, bounds['.//EastLongitude'].text])
        end
      end
    end
  end
end
