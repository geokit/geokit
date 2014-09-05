module Geokit
  module Geocoders
    # OpenCage geocoder implementation.  Requires the Geokit::Geocoders::OpencageGeocoder.key
    # variable to contain an API key.  Conforms to the interface set by the Geocoder class.
    class OpencageGeocoder < Geocoder
      config :key
      self.secure = true

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        options_str = generate_param_for_option(:language, options)
        options_str << generate_param_for_option(:bounds, options)
        options_str << generate_param_for_option(:min_confidence, options)

        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url = "#{protocol}://api.opencagedata.com/geocode/v1/json?"
        url += "key=#{key}#{options_str}&"
        url += "query=#{Geokit::Inflector.url_escape(address_str)}&"
        url += 'no_annotations=1'
        process :json, url
      end
            # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng = LatLng.normalize(latlng)
        url = "#{protocol}://api.opencagedata.com/geocode/v1/json?"
        url += "key=#{key}&query=#{latlng.lat},#{latlng.lng}"
        process :json, url
      end

      def self.generate_param_for(param, value)
        "&#{param}=#{Geokit::Inflector.url_escape(value.to_s)}"
      end

      def self.generate_param_for_option(param, options)
        options[param] ? "&#{param}=#{Geokit::Inflector.url_escape(options[param])}" : ''
      end

      def self.generate_bool_param_for_option(param, options)
        options[param] ? "&#{param}=1" : "&#{param}=0"
      end

      def self.parse_json(results)
        return GeoLoc.new if results.empty?
        if results.is_a?(Hash)
          return GeoLoc.new unless results['status']['message'] == 'OK'
        end

        loc = nil
        results['results'].each do |result|
          extracted_geoloc = extract_geoloc(result)
          if loc.nil?
            loc = extracted_geoloc
          else
            loc.all.push(extracted_geoloc)
          end
        end
        loc
      end

      def self.extract_geoloc(result_json)
        loc = new_loc
        loc.lat = result_json['geometry']['lat']
        loc.lng = result_json['geometry']['lng']
        set_address_components(result_json['components'], loc)
        set_precision(result_json, loc)
        loc.success = true
        loc
      end

      def self.set_address_components(address_data, loc)
        return unless address_data
        loc.country        = address_data['country']
        loc.country_code   = address_data['country_code'].upcase if address_data['country_code']
        loc.state_name     = address_data['state']
        loc.city           = address_data['city']
        loc.city           = address_data['county'] if loc.city.nil? && address_data['county']
        loc.zip            = address_data['postcode']
        loc.district       = address_data['city_district']
        loc.district       = address_data['state_district'] if loc.district.nil? && address_data['state_district']
        loc.street_address = "#{address_data['road']} #{address_data['house_number']}".strip if address_data['road']
        loc.street_name    = address_data['road']
        loc.street_number  = address_data['house_number']
      end

      def self.set_precision(result_json, loc)
        # a value between 1 (worse) and 10 (best). 0 means unknown
        loc.precision = result_json['confidence']
      end
    end
  end
end
