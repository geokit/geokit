module Geokit
  module Geocoders
    # MapQuest geocoder implementation.  Requires the Geokit::Geocoders::MapQuestGeocoder:key
    # variable to contain a MapQuest API key.  Conforms to the interface set by the Geocoder class.
    class MapQuestGeocoder < Geocoder
      config :key
      self.secure = true

      private

      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng = LatLng.normalize(latlng)
        url = "#{protocol}://www.mapquestapi.com/geocoding/v1/reverse?key=#{key}&location=#{latlng.lat},#{latlng.lng}"
        process :json, url
      end

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url = "#{protocol}://www.mapquestapi.com/geocoding/v1/address?key=#{key}&location=#{Geokit::Inflector.url_escape(address_str)}"
        process :json, url
      end

      def self.parse_json(results)
        return GeoLoc.new unless results['info']['statuscode'] == 0
        loc = nil
        results['results'].each do |result|
          result['locations'].each do |location|
            extracted_geoloc = extract_geoloc(location)
            if loc.nil?
              loc = extracted_geoloc
            else
              loc.all.push(extracted_geoloc)
            end
          end
        end
        loc
      end

      def self.extract_geoloc(result_json)
        loc = new_loc
        loc.lat = result_json['latLng']['lat']
        loc.lng = result_json['latLng']['lng']
        set_address_components(result_json, loc)
        set_precision(result_json, loc)
        loc.success = true
        loc
      end

      def self.set_address_components(result_json, loc)
        loc.country_code   = result_json['adminArea1']
        loc.street_address = result_json['street'].to_s.empty? ? nil : result_json['street']
        loc.city           = result_json['adminArea5']
        loc.state          = result_json['adminArea3']
        loc.zip            = result_json['postalCode']
      end

      def self.set_precision(result_json, loc)
        loc.precision = result_json['geocodeQuality']
        loc.accuracy = %w{unknown country state state city zip zip+4 street address building}.index(loc.precision)
      end
    end
  end
end
