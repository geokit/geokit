# frozen_string_literal: true
require 'pry'

module Geokit
  module Geocoders
    class WoosmapGeocoder < Geocoder
      # These do not map well. Perhaps we should guess better based on size
      # of bounding box where it exists? Does it really matter?
      ACCURACY = {
        'ROOFTOP' => 9,
        'RANGE_INTERPOLATED' => 8,
        'POSTAL_CODE' => 7,
        'DISTRICT' => 6,
        'GEOMETRIC_CENTER' => 5,
        'APPROXIMATE' => 4
      }.freeze

      config :api_key, :api_private_key, :api_language, :api_cc_format

      self.secure = true

      # @param [String] latlng
      #   Is used for reverse geocoding.
      #
      # @option options [String] :fields
      #   You can use this parameter to limit the fields returned in the response.
      #   By default, all fields are returned.
      #   Example: +fields: ["geometry"]+
      #
      # @option options [String] :language
      #   The language code, indicating in which language the results should be returned,
      #   when available. If language is not specified, the Localities Geocode endpoint
      #   will use the default language of each country.
      #   Must be a ISO 639-1 language code.
      #   Example: +"es"+ for Spanish.
      #
      # @option options [String] :components
      #   A grouping of places to which you would like to restrict your results.
      #   Components can be used to filter over countries.
      #   Countries must be passed as an ISO 3166-1 Alpha-2 or Alpha-3 country code.
      #   Example: +components: { country: ["fr", "gb", "it"] }+
      #
      #   To restrict the search to metropolitain France, use +"fr-fr".
      #
      # @option options [String] :data
      #   This parameter accepts two values: +"standard"+ (default) or +"advanced"+.
      #
      # @option options [String] :cc_format
      #   To specify the country code format returned in the response.
      #   Possible values are +"alpha2"+ and +"alpha3"+.
      #   Default is the format used to specify +components+ or +"alpha2"+ if no
      #   components are specified.
      #
      def self.do_reverse_geocode(latlng, options = {})
        latlng_str = "latlng=#{build_latlng_query_value(latlng)}"
        url = build_url(latlng_str, options)
        process(:json, url)
      end

      # @param [String] address
      #   The input string to geocode. Can represent an address, a street, a locality or
      #   a postal code.
      #   Example: +"10 Bd du Palais, 75001 Paris, France"+
      #
      # @option options [String] :fields
      #   You can use this parameter to limit the fields returned in the response.
      #   By default, all fields are returned.
      #   Example: +fields: ["geometry"]+
      #
      # @option options [String] :language
      #   The language code, indicating in which language the results should be returned,
      #   when available. If language is not specified, the Localities Geocode endpoint
      #   will use the default language of each country.
      #   Must be a ISO 639-1 language code.
      #   Example: +"es"+ for Spanish.
      #
      # @option options [String] :components
      #   A grouping of places to which you would like to restrict your results.
      #   Components can be used to filter over countries.
      #   Countries must be passed as an ISO 3166-1 Alpha-2 or Alpha-3 country code.
      #   To restrict the search to metropolitain France, use +"fr-fr".
      #   Example: +components: { country: ["fr", "gb", "it"] }+
      #
      # @option options [String] :data
      #   This parameter accepts two values: +"standard"+ (default) or +"advanced"+.
      #
      # @option options [String] :cc_format
      #   To specify the country code format returned in the response.
      #   Possible values are +"alpha2"+ and +"alpha3"+.
      #   Default is the format used to specify +components+ or +"alpha2"+ if no
      #   components are specified.
      #
      def self.do_geocode(address, options = {})
        address_formatted = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        address_str = "address=#{Geokit::Inflector.url_escape(address_formatted)}"
        url = build_url(address_str, options)
        process(:json, url)
      end

      def self.build_url(query_string, options = {})
        if options[:fields]
          value = build_filter_query_value(options[:fields])
          query_string = "#{query_string}&fields=#{value}"
        end
        if options.fetch(:language, api_language)
          value = options.fetch(:language, api_language).downcase
          query_string = "#{query_string}&language=#{value}"
        end
        if options[:components]
          value = build_filter_query_value(options[:components])
          query_string = "#{query_string}&components=#{value}"
        end
        if options[:data]
          query_string = "#{query_string}&data=#{options[:data]}"
        end
        if options.fetch(:cc_format, api_cc_format)
          query_string = "#{query_string}&cc_format=#{options.fetch(:cc_format, api_cc_format)}"
        end
        if api_private_key
          query_string = "#{query_string}&private_key=#{api_private_key}"
        elsif api_key
          query_string = "#{query_string}&key=#{api_key}"
        end
        "#{protocol}://api.woosmap.com/localities/geocode?#{query_string}"
      end

      def self.build_filter_query_value(components = {})
        return if components.empty?
        components_formatted = components.flat_map do |key, values|
          Array(values).map { |value| "#{key}:#{value.to_s.downcase}" }
        end.join("|")
        Geokit::Inflector.url_escape(components_formatted)
      end

      def self.build_latlng_query_value(latlng = nil)
        return unless latlng
        Geokit::Inflector.url_escape(LatLng.normalize(latlng).ll)
      end

      def self.parse_json(response)
        if response.key?("results")
          unsorted = response.fetch("results").map do |addr|
            single_json_to_geoloc(addr)
          end
          sorted = unsorted.sort { |a, b| b.accuracy <=> a.accuracy }
          encoded = sorted.first
          encoded.all = sorted
          encoded
        else
          raise Geokit::Geocoders::GeocodeError, response
        end
      end

      def self.single_json_to_geoloc(addr)
        loc = new_loc
        loc.success = true
        loc.full_address = addr.fetch("formatted_address")
        loc.formatted_address = addr.fetch("formatted_address")
        set_address_components(loc, addr)
        set_precision(loc, addr)
        set_coords(loc, addr)
        set_bounds(loc, addr)
        loc
      end

      def self.set_coords(loc, addr)
        location = addr.fetch("geometry").fetch("location")
        loc.lat = location.fetch("lat").to_f
        loc.lng = location.fetch("lng").to_f
      end

      def self.set_bounds(loc, addr)
        geometry = addr.fetch("geometry")
        return unless geometry.key?("viewport")
        viewport = geometry.fetch("viewport")
        ne = Geokit::LatLng.from_json(viewport.fetch("northeast"))
        sw = Geokit::LatLng.from_json(viewport.fetch("southwest"))
        loc.suggested_bounds = Geokit::Bounds.new(sw, ne)
      end

      def self.set_address_components(loc, addr)
        addr.fetch("address_components").each do |comp|
          types = comp.fetch("types")
          if types.include?("country") || types.include?("administrative_area_level_0")
            loc.country_code = comp.fetch("short_name")
            loc.country = comp.fetch("long_name")
          elsif types.include?("administrative_area_level_1")
            loc.state = comp.fetch("long_name")
          elsif types.include?("administrative_area_level_2")
            loc.county = comp.fetch("long_name")
          elsif types.include?("locality") || types.include?("postal_town")
            loc.city = comp.fetch("long_name")
          elsif types.include?("postal_codes")
            postal_codes = comp.fetch("long_name")
            loc.zip = if postal_codes.is_a?(Array) && postal_codes.one?
                        postal_codes.first
                      else
                        postal_codes
                      end
          elsif types.include?("route")
            loc.street_name = comp.fetch("long_name")
          elsif types.include?("street_number")
            loc.street_number = comp.fetch("short_name")
          end
        end

        if addr.fetch("types").include?("postal_code")
          loc.zip ||= addr.fetch("name")
        elsif addr.fetch("types").include?("locality")
          loc.city ||= addr.fetch("name")
        end

        if loc.street_name
          loc.street_address = [loc.street_number, loc.street_name].join(' ').strip
        end
      end

      def self.set_precision(loc, addr)
        loc.accuracy = ACCURACY[addr.dig("geometry", "location_type")]
        address_components = addr.fetch("address_components")
        loc.precision = if address_components.empty?
                          "unknown"
                        else
                          [address_components.size, 9].min
                        end
      end
    end
  end
end
