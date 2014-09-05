module Geokit
  module Geocoders
    # Mapbox geocoder implementation.  Requires the Geokit::Geocoders::MapboxGeocoder:key variable to
    # contain a Mapbox access token.  Conforms to the interface set by the Geocoder class.
    class MapboxGeocoder < Geocoder
      config :key
      self.secure = true

      private

      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng = LatLng.normalize(latlng)
        url =  "#{protocol}://api.tiles.mapbox.com/v4/geocode/mapbox.places-v1/"
        url += "#{latlng.lng},#{latlng.lat}.json?access_token=#{key}"
        process :json, url
      end

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url =  "#{protocol}://api.tiles.mapbox.com/v4/geocode/mapbox.places-v1/"
        url += "#{Geokit::Inflector.url_escape(address_str)}.json?access_token=#{key}"
        process :json, url
      end

      def self.parse_json(results)
        return GeoLoc.new unless results['features'].count > 0
        loc = nil
        results['features'].each do |feature|
          extracted_geoloc = extract_geoloc(feature)
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
        loc.lng = result_json['center'][0]
        loc.lat = result_json['center'][1]
        set_address_components(result_json, loc)
        set_precision(loc)
        set_bounds(result_json['bbox'], loc)
        loc.success = true
        loc
      end

      def self.set_address_components(result_json, loc)
        if result_json['context']
          result_json['context'].each do |context|
            if context['id'] =~ /^country\./
              loc.country = context['text']
            elsif context['id'] =~ /^province\./
              loc.state = context['text']
            elsif context['id'] =~ /^city\./
              loc.city = context['text']
            elsif context['id'] =~ /^postcode-/
              loc.zip = context['text']
              loc.country_code = context['id'].split('.')[0].gsub(/^postcode-/, '').upcase
            end
          end
          if loc.country_code && !loc.country
            loc.country = loc.country_code
          end
        end
        if result_json['place_name']
          loc.full_address = result_json['place_name']
        end
      end

      PRECISION_VALUES = %w{unknown country state city zip full_address}

      def self.set_precision(loc)
        for i in 1...PRECISION_VALUES.length - 1
          if loc.send(PRECISION_VALUES[i]) && loc.send(PRECISION_VALUES[i]).length
            loc.precision = PRECISION_VALUES[i]
          else
            break
          end
        end
      end

      def self.set_bounds(result_json, loc)
        if bounds = result_json
          loc.suggested_bounds = Bounds.normalize([bounds[1], bounds[0]], [bounds[3], bounds[2]])
        end
      end
    end
  end
end
