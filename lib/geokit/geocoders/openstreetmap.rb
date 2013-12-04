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

        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address

        #url="http://where.yahooapis.com/geocode?flags=J&appid=#{Geokit::Geocoders::yahoo}&q=#{Geokit::Inflector::url_escape(address_str)}"
        url="http://nominatim.openstreetmap.org/search?format=json#{options_str}&addressdetails=1&q=#{Geokit::Inflector::url_escape(address_str)}"
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        json = res.body
        logger.debug "OSM geocoding. Address: #{address}. Result: #{json}"
        return self.json2GeoLoc(json, address)
      end

      def self.do_reverse_geocode(latlng, options = {})
        latlng = LatLng.normalize(latlng)
        options_str = generate_param_for(:lat, latlng.lat)
        options_str << generate_param_for(:lon, latlng.lng)
        options_str << generate_param_for_option(:zoom, options)
        options_str << generate_param_for_option(:osm_type, options)
        options_str << generate_param_for_option(:osm_id, options)
        options_str << generate_param_for_option(:json_callback, options)
        url = "http://nominatim.openstreetmap.org/reverse?format=json&addressdetails=1#{options_str}"
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        json = res.body
        logger.debug "OSM reverse geocoding: Lat: #{latlng.lat}, Lng: #{latlng.lng}. Result: #{json}"
        return self.json2GeoLoc(json, latlng)
      end

      def self.generate_param_for(param, value)
        "&#{param}=#{Geokit::Inflector::url_escape(value.to_s)}"
      end

      def self.generate_param_for_option(param, options)
        options[param] ? "&#{param}=#{Geokit::Inflector::url_escape(options[param])}" : ''
      end

      def self.generate_bool_param_for_option(param, options)
        options[param] ? "&#{param}=1" : "&#{param}=0"
      end

      def self.json2GeoLoc(json, obj)
        results = MultiJson.load(json)
        if results.is_a?(Hash)
          return GeoLoc.new if results['error']
          results = [results]
        end
        unless results.empty?
          geoloc = nil
          results.each do |result|
            extract_geoloc = extract_geoloc(result)
            if geoloc.nil?
              geoloc = extract_geoloc
            else
              geoloc.all.push(extract_geoloc)
            end
          end
          return geoloc
        else
          logger.info "OSM was unable to geocode #{obj}"
          return GeoLoc.new
        end
      end

      def self.extract_geoloc(result_json)
        geoloc = GeoLoc.new

        # basic
        geoloc.lat = result_json['lat']
        geoloc.lng = result_json['lon']

        geoloc.provider = 'osm'
        geoloc.precision = result_json['class']
        geoloc.accuracy = result_json['type']

        # Todo accuracy does not work as Yahoo and Google maps on OSM
        #geoloc.accuracy = %w{unknown amenity building highway historic landuse leisure natural place railway shop tourism waterway man_made}.index(geoloc.precision)
        #geoloc.full_address = result_json['display_name']
        if result_json['address']
          address_data = result_json['address']

          geoloc.country = address_data['country']
          geoloc.country_code = address_data['country_code'].upcase if address_data['country_code']
          geoloc.state = address_data['state']
          geoloc.city = address_data['city']
          geoloc.city = address_data['county'] if geoloc.city.nil? && address_data['county']
          geoloc.zip = address_data['postcode']
          geoloc.district = address_data['city_district']
          geoloc.district = address_data['state_district'] if geoloc.district.nil? && address_data['state_district']
          geoloc.street_address = "#{address_data['road']} #{address_data['house_number']}".strip if address_data['road']
          geoloc.street_name = address_data['road']
          geoloc.street_number = address_data['house_number']
        end

        if result_json['boundingbox']
          geoloc.suggested_bounds = Bounds.normalize(
              [result_json['boundingbox'][0], result_json['boundingbox'][1]],
              [result_json['boundingbox'][2], result_json['boundingbox'][3]])
        end

        geoloc.success = true

        return geoloc
      end
    end
  end
end
