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
        if (@poly_y[i] < y && @poly_y[j] >= y ||
            @poly_y[j] < y && @poly_y[i] >= y)
          if (@poly_x[i] + (y - @poly_y[i]) / (@poly_y[j] - @poly_y[i]) * (@poly_x[j] - @poly_x[i]) < x)
            oddNodes = !oddNodes
          end
        end
 
        j=i
      end

      oddNodes
    end # contains?
  end # class Polygon
end
