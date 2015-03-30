module Geokit
  class LatLng
    include Mappable

    attr_accessor :lat, :lng

    # Provide users with the ability to use :latitude and :longitude
    # to access the lat/lng instance variables.
    # Alias the attr_accessor :lat to :latitude
    alias_method :latitude, :lat
    alias_method :latitude=, :lat=
    # Alias the attr_accessor :lng to :longitude
    alias_method :longitude, :lng
    alias_method :longitude=, :lng=

    # Accepts latitude and longitude or instantiates an empty instance
    # if lat and lng are not provided. Converted to floats if provided
    def initialize(lat = nil, lng = nil)
      lat = lat.to_f if lat && !lat.is_a?(Numeric)
      lng = lng.to_f if lng && !lng.is_a?(Numeric)
      @lat = lat
      @lng = lng
    end

    def self.from_json(json)
      new(json['lat'], json['lng'])
    end

    # Latitude attribute setter; stored as a float.
    def lat=(lat)
      @lat = lat.to_f if lat
    end

    # Longitude attribute setter; stored as a float;
    def lng=(lng)
      @lng = lng.to_f if lng
    end

    # Returns the lat and lng attributes as a comma-separated string.
    def ll
      "#{lat},#{lng}"
    end

    # returns latitude as [ degree, minute, second ] array
    def lat_dms
      self.class.decimal_to_dms(lat)
    end

    # returns longitude as [ degree, minute, second ] array
    def lng_dms
      self.class.decimal_to_dms(lng)
    end

    # returns a string with comma-separated lat,lng values
    def to_s
      ll
    end

    # returns a two-element array
    def to_a
      [lat, lng]
    end

    # Returns true if the candidate object is logically equal. Logical
    # equivalence is true if the lat and lng attributes are the same for both
    # objects.
    def ==(other)
      return false unless other.is_a?(LatLng)
      lat == other.lat && lng == other.lng
    end

    def hash
      lat.hash + lng.hash
    end

    def eql?(other)
      self == other
    end

    # Returns true if both lat and lng attributes are defined
    def valid?
      lat && lng
    end

    # A *class* method to take anything which can be inferred as a point and
    # generate a LatLng from it. You should use this anything you're not sure
    # what the input is, and want to deal with it as a LatLng if at all
    # possible. Can take:
    #  1) two arguments (lat,lng)
    #  2) a string in the format "37.1234,-129.1234" or "37.1234 -129.1234"
    #  3) a string which can be geocoded on the fly
    #  4) an array in the format [37.1234,-129.1234]
    #  5) a LatLng or GeoLoc (which is just passed through as-is)
    #  6) anything responding to to_lat_lng -- a LatLng will be extracted from
    #     it
    def self.normalize(thing, other = nil)
      return Geokit::LatLng.new(thing, other) if other

      case thing
      when String
        from_string(thing)
      when Array
        thing.size == 2 or raise ArgumentError.new(
          'Must initialize with an Array with both latitude and longitude')
        Geokit::LatLng.new(thing[0], thing[1])
      when LatLng # will also be true for GeoLocs
        thing
      else
        if thing.respond_to? :to_lat_lng
          thing.to_lat_lng
        else
          raise ArgumentError.new(
            "#{thing} (#{thing.class}) cannot be normalized to a LatLng. " +
            "We tried interpreting it as an array, string, etc., but no dice.")
        end
      end
    end

    def self.from_string(thing)
      thing.strip!
      if match = thing.match(/(\-?\d+\.?\d*)[, ] ?(\-?\d+\.?\d*)$/)
        Geokit::LatLng.new(match[1], match[2])
      else
        res = Geokit::Geocoders::MultiGeocoder.geocode(thing)
        return res if res.success?
        raise Geokit::Geocoders::GeocodeError
      end
    end

    # Reverse geocodes a LatLng object using the MultiGeocoder (default), or
    # optionally using a geocoder of your choosing. Returns a new Geokit::GeoLoc
    # object
    #
    # ==== Options
    # * :using  - Specifies the geocoder to use for reverse geocoding. Defaults
    #             to MultiGeocoder. Can be either the geocoder class (or any
    #             class that implements do_reverse_geocode for that matter), or
    #             the name of the class without the "Geocoder" part
    #             (e.g. :google)
    #
    # ==== Examples
    # LatLng.new(51.4578329, 7.0166848).reverse_geocode
    # => #<Geokit::GeoLoc:0x12dac20 @state...>
    # LatLng.new(51.4578329, 7.0166848).reverse_geocode(:using => :google)
    # => #<Geokit::GeoLoc:0x12dac20 @state...>
    # LatLng.new(51.4578329, 7.0166848).reverse_geocode(:using =>
    #   Geokit::Geocoders::GoogleGeocoder)
    # => #<Geokit::GeoLoc:0x12dac20 @state...>
    def reverse_geocode(options = { using: Geokit::Geocoders::MultiGeocoder })
      if options[:using].is_a?(String) || options[:using].is_a?(Symbol)
        class_name =
          "#{Geokit::Inflector.camelize(options[:using].to_s)}Geocoder"
        provider = Geokit::Geocoders.const_get(class_name)
      elsif options[:using].respond_to?(:do_reverse_geocode)
        provider = options[:using]
      else
        raise ArgumentError.new("#{options[:using]} is not a valid geocoder.")
      end

      provider.send(:reverse_geocode, self)
    end
  end
end
