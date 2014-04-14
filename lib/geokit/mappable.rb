#require 'forwardable'

module Geokit
  # Contains class and instance methods providing distance calcuation services.  This
  # module is meant to be mixed into classes containing lat and lng attributes where
  # distance calculation is desired.
  #
  # At present, two forms of distance calculations are provided:
  #
  # * Pythagorean Theory (flat Earth) - which assumes the world is flat and loses accuracy over long distances.
  # * Haversine (sphere) - which is fairly accurate, but at a performance cost.
  #
  # Distance units supported are :miles, :kms, and :nms.
  module Mappable
    PI_DIV_RAD = 0.0174
    KMS_PER_MILE = 1.609
    NMS_PER_MILE = 0.868976242
    EARTH_RADIUS_IN_MILES = 3963.19
    EARTH_RADIUS_IN_KMS = EARTH_RADIUS_IN_MILES * KMS_PER_MILE
    EARTH_RADIUS_IN_NMS = EARTH_RADIUS_IN_MILES * NMS_PER_MILE
    MILES_PER_LATITUDE_DEGREE = 69.1
    KMS_PER_LATITUDE_DEGREE = MILES_PER_LATITUDE_DEGREE * KMS_PER_MILE
    NMS_PER_LATITUDE_DEGREE = MILES_PER_LATITUDE_DEGREE * NMS_PER_MILE
    LATITUDE_DEGREES = EARTH_RADIUS_IN_MILES / MILES_PER_LATITUDE_DEGREE

    # Mix below class methods into the includer.
    def self.included(receiver) # :nodoc:
      receiver.extend ClassMethods
    end

    module ClassMethods #:nodoc:
      # Returns the distance between two points.  The from and to parameters are
      # required to have lat and lng attributes.  Valid options are:
      # :units - valid values are :miles, :kms, :nms (Geokit::default_units is the default)
      # :formula - valid values are :flat or :sphere (Geokit::default_formula is the default)
      def distance_between(from, to, options={})
        from=Geokit::LatLng.normalize(from)
        to=Geokit::LatLng.normalize(to)
        return 0.0 if from == to # fixes a "zero-distance" bug
        units = options[:units] || Geokit::default_units
        formula = options[:formula] || Geokit::default_formula
        case formula
        when :sphere then distance_between_sphere(from, to, units)
        when :flat   then distance_between_flat(from, to, units)
        end
      end

      def distance_between_sphere(from, to, units)
        lat_sin = Math.sin(deg2rad(from.lat)) * Math.sin(deg2rad(to.lat))
        lat_cos = Math.cos(deg2rad(from.lat)) * Math.cos(deg2rad(to.lat))
        lng_cos = Math.cos(deg2rad(to.lng) - deg2rad(from.lng))
        units_sphere_multiplier(units) * Math.acos(lat_sin + lat_cos * lng_cos)
      rescue *math_error_classes
        0.0
      end

      def distance_between_flat(from, to, units)
        lat_length = units_per_latitude_degree(units) * (from.lat - to.lat)
        lng_length = units_per_longitude_degree(from.lat, units) * (from.lng - to.lng)
        Math.sqrt(lat_length ** 2 + lng_length ** 2)
      end

      # Ruby 1.9 raises {Math::DomainError}, but it is not defined in Ruby 1.8
      def math_error_classes
        return [Errno::EDOM, Math::DomainError] if defined?(Math::DomainError)
        [Errno::EDOM]
      end

      # Returns heading in degrees (0 is north, 90 is east, 180 is south, etc)
      # from the first point to the second point. Typicaly, the instance methods will be used
      # instead of this method.
      def heading_between(from,to)
        from=Geokit::LatLng.normalize(from)
        to=Geokit::LatLng.normalize(to)

        d_lng=deg2rad(to.lng-from.lng)
        from_lat=deg2rad(from.lat)
        to_lat=deg2rad(to.lat)
        y=Math.sin(d_lng) * Math.cos(to_lat)
        x=Math.cos(from_lat)*Math.sin(to_lat)-Math.sin(from_lat)*Math.cos(to_lat)*Math.cos(d_lng)
        heading=to_heading(Math.atan2(y,x))
      end

      # Given a start point, distance, and heading (in degrees), provides
      # an endpoint. Returns a LatLng instance. Typically, the instance method
      # will be used instead of this method.
      def endpoint(start,heading, distance, options={})
        units   = options[:units] || Geokit::default_units
        ratio   = distance.to_f / units_sphere_multiplier(units)
        start   = Geokit::LatLng.normalize(start)
        lat     = deg2rad(start.lat)
        lng     = deg2rad(start.lng)
        heading = deg2rad(heading)

        sin_ratio = Math.sin(ratio)
        cos_ratio = Math.cos(ratio)
        sin_lat = Math.sin(lat)
        cos_lat = Math.cos(lat)

        end_lat = Math.asin(sin_lat * cos_ratio +
                            cos_lat * sin_ratio * Math.cos(heading))

        end_lng = lng + Math.atan2(Math.sin(heading) * sin_ratio * cos_lat,
                                   cos_ratio - sin_lat * Math.sin(end_lat))

        LatLng.new(rad2deg(end_lat),rad2deg(end_lng))
      end

      # Returns the midpoint, given two points. Returns a LatLng.
      # Typically, the instance method will be used instead of this method.
      # Valid option:
      #   :units - valid values are :miles, :kms, or :nms (:miles is the default)
      def midpoint_between(from,to,options={})
        from=Geokit::LatLng.normalize(from)

        units = options[:units] || Geokit::default_units

        heading=from.heading_to(to)
        distance=from.distance_to(to,options)
        midpoint=from.endpoint(heading,distance/2,options)
      end

      # Geocodes a location using the multi geocoder.
      def geocode(location, options = {})
        res = Geocoders::MultiGeocoder.geocode(location, options)
        return res if res.success?
        raise Geokit::Geocoders::GeocodeError
      end

      # Given a decimal degree like -87.660333
      # return a 3-element array like [ -87, 39, 37.198... ]
      def decimal_to_dms(deg)
        return false unless deg.is_a?(Numeric)
        # seconds is 0...3599.999, representing the entire fractional part.
        seconds = (deg.abs % 1.0) * 3600.0
        [
            deg.to_i,               # degrees as positive or negative integer
            (seconds / 60).to_i,    # minutes as positive integer
            (seconds % 60)          # seconds as positive float
        ]
      end
      
      protected

      def deg2rad(degrees)
        degrees.to_f / 180.0 * Math::PI
      end

      def rad2deg(rad)
        rad.to_f * 180.0 / Math::PI
      end

      def to_heading(rad)
        (rad2deg(rad)+360)%360
      end

      # Returns the multiplier used to obtain the correct distance units.
      def units_sphere_multiplier(units)
        case units
          when :kms; EARTH_RADIUS_IN_KMS
          when :nms; EARTH_RADIUS_IN_NMS
          else EARTH_RADIUS_IN_MILES
        end
      end

      # Returns the number of units per latitude degree.
      def units_per_latitude_degree(units)
        case units
          when :kms; KMS_PER_LATITUDE_DEGREE
          when :nms; NMS_PER_LATITUDE_DEGREE
          else MILES_PER_LATITUDE_DEGREE
        end
      end

      # Returns the number units per longitude degree.
      def units_per_longitude_degree(lat, units)
        miles_per_longitude_degree = (LATITUDE_DEGREES * Math.cos(lat * PI_DIV_RAD)).abs
        case units
          when :kms; miles_per_longitude_degree * KMS_PER_MILE
          when :nms; miles_per_longitude_degree * NMS_PER_MILE
          else miles_per_longitude_degree
        end
      end
    end

    # -----------------------------------------------------------------------------------------------
    # Instance methods below here
    # -----------------------------------------------------------------------------------------------

    # Extracts a LatLng instance. Use with models that are acts_as_mappable
    def to_lat_lng
      return self if instance_of?(Geokit::LatLng) || instance_of?(Geokit::GeoLoc)
      return LatLng.new(send(self.class.lat_column_name), send(self.class.lng_column_name))
      nil
    end

    # Returns the distance from another point.  The other point parameter is
    # required to have lat and lng attributes.  Valid options are:
    # :units - valid values are :miles, :kms, :or :nms (:miles is the default)
    # :formula - valid values are :flat or :sphere (:sphere is the default)
    def distance_to(other, options={})
      self.class.distance_between(self, other, options)
    end
    alias distance_from distance_to

    # Returns heading in degrees (0 is north, 90 is east, 180 is south, etc)
    # to the given point. The given point can be a LatLng or a string to be Geocoded
    def heading_to(other)
      self.class.heading_between(self,other)
    end

    # Returns heading in degrees (0 is north, 90 is east, 180 is south, etc)
    # FROM the given point. The given point can be a LatLng or a string to be Geocoded
    def heading_from(other)
      self.class.heading_between(other,self)
    end

    # Returns the endpoint, given a heading (in degrees) and distance.
    # Valid option:
    # :units - valid values are :miles, :kms, or :nms (:miles is the default)
    def endpoint(heading,distance,options={})
      self.class.endpoint(self,heading,distance,options)
    end

    # Returns the midpoint, given another point on the map.
    # Valid option:
    # :units - valid values are :miles, :kms, or :nms (:miles is the default)
    def midpoint_to(other, options={})
      self.class.midpoint_between(self,other,options)
    end

  end

end
