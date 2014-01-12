module Geokit
  # A complex polygon made of multiple points.  End point must equal start point to close the poly.
  class Polygon
    
    attr_accessor :poly_y, :poly_x
    
    def initialize(points)
      # Pass in an array of Geokit::LatLng
      @poly_x = []
      @poly_y = []

      points.each do |point|
        @poly_x << point.lng
        @poly_y << point.lat
      end
      
      # A Polygon must be 'closed', the last point equal to the first point
      if @poly_x[0] != @poly_x[-1] || @poly_y[0] != @poly_y[-1]
        # Append the first point to the array to close the polygon
        @poly_x << @poly_x[0]
        @poly_y << @poly_y[0]
      end
      
    end

    def contains?(point)
      j = @poly_x.length - 1
      oddNodes = false
      x = point.lng
      y = point.lat

      for i in (0..j)
        yi = @poly_y[i]
        xi = @poly_x[i]
        yj = @poly_y[j]
        xj = @poly_x[j]
        if (yi < y && yj >= y ||
            yj < y && yi >= y)
          if (xi + (y - yi) / (yj - yi) * (xj - xi) < x)
            oddNodes = !oddNodes
          end
        end
 
        j=i
      end

      oddNodes
    end # contains?
  end # class Polygon
end
