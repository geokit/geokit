module Geokit
  # Bounds represents a rectangular bounds, defined by the SW and NE corners
  class Bounds
    # sw and ne are LatLng objects
    attr_accessor :sw, :ne

    # provide sw and ne to instantiate a new Bounds instance
    def initialize(sw, ne)
      if !(sw.is_a?(Geokit::LatLng) && ne.is_a?(Geokit::LatLng))
        raise ArgumentError
      end
      @sw, @ne = sw, ne
    end

    # returns the a single point which is the center of the rectangular bounds
    def center
      @sw.midpoint_to(@ne)
    end

    # a simple string representation:sw,ne
    def to_s
      "#{@sw},#{@ne}"
    end

    # a two-element array of two-element arrays: sw,ne
    def to_a
      [@sw.to_a, @ne.to_a]
    end

    # Returns true if the bounds contain the passed point.
    # allows for bounds which cross the meridian
    def contains?(point)
      point = Geokit::LatLng.normalize(point)
      res = point.lat > @sw.lat && point.lat < @ne.lat
      if crosses_meridian?
        res &= point.lng < @ne.lng || point.lng > @sw.lng
      else
        res &= point.lng < @ne.lng && point.lng > @sw.lng
      end
      res
    end

    # returns true if the bounds crosses the international dateline
    def crosses_meridian?
      @sw.lng > @ne.lng
    end

    # Returns true if the candidate object is logically equal. Logical
    # equivalence is true if the lat and lng attributes are the same for both
    # objects.
    def ==(other)
      return false unless other.is_a?(Bounds)
      sw == other.sw && ne == other.ne
    end

    # Equivalent to Google Maps API's .toSpan() method on GLatLng's.
    #
    # Returns a LatLng object, whose coordinates represent the size of a
    # rectangle defined by these bounds.
    def to_span
      lat_span = @ne.lat - @sw.lat
      lng_span = crosses_meridian? ? 360 + @ne.lng - @sw.lng : @ne.lng - @sw.lng
      Geokit::LatLng.new(lat_span.abs, lng_span.abs)
    end

    class <<self
      # returns an instance of bounds which completely encompases the given
      # circle
      def from_point_and_radius(point, radius, options = {})
        point = LatLng.normalize(point)
        p0 = point.endpoint(0, radius, options)
        p90 = point.endpoint(90, radius, options)
        p180 = point.endpoint(180, radius, options)
        p270 = point.endpoint(270, radius, options)
        sw = Geokit::LatLng.new(p180.lat, p270.lng)
        ne = Geokit::LatLng.new(p0.lat, p90.lng)
        Geokit::Bounds.new(sw, ne)
      end

      # Takes two main combinations of arguments to create a bounds:
      # point,point   (this is the only one which takes two arguments
      # [point,point]
      # . . . where a point is anything LatLng#normalize can handle
      #       (which is quite a lot)
      #
      # NOTE: everything combination is assumed to pass points in the order
      # sw, ne
      def normalize (thing, other = nil)
        # maybe this will be simple -- an actual bounds object is passed, and
        # we can all go home
        return thing if thing.is_a? Bounds

        # no? OK, if there's no "other," the thing better be a two-element array
        thing, other = thing if !other && thing.is_a?(Array) && thing.size == 2

        # Now that we're set with a thing and another thing, let LatLng do the
        # heavy lifting.
        # Exceptions may be thrown
        thing_ll = Geokit::LatLng.normalize(thing)
        other_ll = Geokit::LatLng.normalize(other)
        Bounds.new(thing_ll, other_ll)
      end
    end
  end
end
