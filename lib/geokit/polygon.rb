module Geokit
  # A complex polygon made of multiple points.  End point must equal start point to close the poly.
  class Polygon
    
    attr_accessor :points
    
    # Pass in an array of Geokit::LatLng
    def initialize(points)
      @points = points
      
      # A Polygon must be 'closed', the last point equal to the first point
      # Append the first point to the array to close the polygon
      @points << points[0] if points[0] != points[-1]
    end

    def contains?(point)
      last_point = @points[-1]
      oddNodes = false
      x = point.lng
      y = point.lat

      for p in @points
        yi = p.lat
        xi = p.lng
        yj = last_point.lat
        xj = last_point.lng
        if (yi < y && yj >= y ||
            yj < y && yi >= y)
          if (xi + (y - yi) / (yj - yi) * (xj - xi) < x)
            oddNodes = !oddNodes
          end
        end
 
        last_point = p
      end

      oddNodes
    end # contains?
  end # class Polygon
end
