module Geokit
  module Geocoders
    # Open Street Map geocoder implementation.
    class OSMGeocoder < Geocoder
      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        options_str = generate_bool_param_for_option(:polygon, options)
        options_str << generate_param_for_option(:json_callback, options)
        options_str << generate_param_for_option(:countrycodes, options)
        options_str << generate_param_for_option(:viewbox, options)
        options_str << generate_param_for_option(:'accept-language', options)
        options_str << generate_param_for_option(:email, options)

        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address

        url = "http://nominatim.openstreetmap.org/search?format=json#{options_str}&addressdetails=1&q=#{Geokit::Inflector.url_escape(address_str)}"
        process :json, url
      end

      def self.do_reverse_geocode(latlng, options = {})
        latlng = LatLng.normalize(latlng)
        options_str = generate_param_for(:lat, latlng.lat)
        options_str << generate_param_for(:lon, latlng.lng)
        options_str << generate_param_for_option(:'accept-language', options)
        options_str << generate_param_for_option(:email, options)
        options_str << generate_param_for_option(:zoom, options)
        options_str << generate_param_for_option(:osm_type, options)
        options_str << generate_param_for_option(:osm_id, options)
        options_str << generate_param_for_option(:json_callback, options)
        url = "http://nominatim.openstreetmap.org/reverse?format=json&addressdetails=1#{options_str}"
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
        if results.is_a?(Hash)
          return GeoLoc.new if results['error']
          results = [results]
        end
        return GeoLoc.new if results.empty?

        loc = nil
        results.each do |result|
          extract_geoloc = extract_geoloc(result)
          if loc.nil?
            loc = extract_geoloc
          else
            loc.all.push(extract_geoloc)
          end
        end
        loc
      end

      def self.extract_geoloc(result_json)
        loc = new_loc

        # basic
        loc.lat = result_json['lat']
        loc.lng = result_json['lon']

        set_address_components(result_json['address'], loc)
        set_precision(result_json, loc)
        set_bounds(result_json['boundingbox'], loc)
        loc.success = true

        loc
      end

      def self.set_address_components(address_data, loc)
        return unless address_data
        loc.country = address_data['country']
        loc.country_code = address_data['country_code'].upcase if address_data['country_code']
        loc.state_name = address_data['state']
        loc.city = address_data['city']
        loc.city = address_data['county'] if loc.city.nil? && address_data['county']
        loc.zip = address_data['postcode']
        loc.district = address_data['city_district']
        loc.district = address_data['state_district'] if loc.district.nil? && address_data['state_district']
        loc.street_address = "#{address_data['road']} #{address_data['house_number']}".strip if address_data['road']
        loc.street_name = address_data['road']
        loc.street_number = address_data['house_number']
      end

      def self.set_precision(result_json, loc)
        # Todo accuracy does not work as Yahoo and Google maps on OSM
        # loc.accuracy = %w{unknown amenity building highway historic landuse leisure natural place railway shop tourism waterway man_made}.index(loc.precision)
        loc.precision = result_json['class']
        loc.accuracy = result_json['type']
      end

      def self.set_bounds(result_json, loc)
        return unless result_json
        loc.suggested_bounds = Bounds.normalize(
            [result_json[0], result_json[1]],
            [result_json[2], result_json[3]])
      end
    end
  end
end
