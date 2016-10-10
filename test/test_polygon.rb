# encoding: utf-8
require File.join(File.dirname(__FILE__), 'helper')

class PolygonTest < Test::Unit::TestCase #:nodoc: all
  def setup
    # Create a simple square-ish polygon for easy testing
    @p1 = Geokit::LatLng.new(45.3142533036254, -93.47527313511819)
    @p2 = Geokit::LatLng.new(45.31232182518015, -93.34893036168069)
    @p3 = Geokit::LatLng.new(45.23694281999268, -93.35167694371194)
    @p4 = Geokit::LatLng.new(45.23500870841669, -93.47801971714944)
    @p5 = Geokit::LatLng.new(45.3142533036254, -93.47527313511819)

    @points = [@p1, @p2, @p3, @p4, @p5]
    @polygon = Geokit::Polygon.new(@points)

    @point_inside = Geokit::LatLng.new(45.27428243796789, -93.41648483416066)
    @point_outside = Geokit::LatLng.new(45.45411010558687, -93.78151703160256)

    # Create a more complex polygon with overlapping lines.  Looks like a star of david
    @c1 = Geokit::LatLng.new(45.48661334374487, -93.74665833078325)
    @c2 = Geokit::LatLng.new(45.53521281284293, -93.32611083984375)
    @c3 = Geokit::LatLng.new(45.28648197278281, -93.3673095703125)
    @c4 = Geokit::LatLng.new(45.31497759107127, -93.75764465890825)
    @c5 = Geokit::LatLng.new(45.36179519142128, -93.812255859375)
    @c6 = Geokit::LatLng.new(45.40230699238177, -93.74908447265625)
    @c7 = Geokit::LatLng.new(45.236217535866025, -93.60076904296875)
    @c8 = Geokit::LatLng.new(45.39989638818863, -93.282485967502)
    @c9 = Geokit::LatLng.new(45.565986795411376, -93.5760498046875)
    @c10 = Geokit::LatLng.new(45.4345991655272, -93.73017883859575)
    @c11 = Geokit::LatLng.new(45.48661334374487, -93.74665833078325)

    @complex_points = [@c1, @c2, @c3, @c4, @c5, @c6, @c7, @c8, @c9, @c10, @c11]
    @complex_polygon = Geokit::Polygon.new(@complex_points)

    # Test three points that should be "inside" this complex shape
    @complex_inside_one = Geokit::LatLng.new(45.52438983143154, -93.59818268101662)
    @complex_inside_two = Geokit::LatLng.new(45.50321887154943, -93.37845611851662)
    @complex_inside_three = Geokit::LatLng.new(45.28334174918666, -93.59543609898537)

    # Test three points that should be "outside" this complex shape
    @complex_outside_one = Geokit::LatLng.new(45.45314676076135, -93.563850405626)
    @complex_outside_two = Geokit::LatLng.new(45.30435378077673, -93.6859130859375)
    @complex_outside_three = Geokit::LatLng.new(45.538820010517036, -93.486946108751)

    # Test open sided polygon aka line - for closing on initialize
    @op1 = Geokit::LatLng.new(44.97402795596173, -92.7297592163086)
    @op2 = Geokit::LatLng.new(44.97395509241393, -92.68448066781275)
    @op3 = Geokit::LatLng.new(44.94455954512172, -92.68413734505884)
    @op4 = Geokit::LatLng.new(44.94383053857761, -92.72876930306666)

    @open_points = [@op1, @op2, @op3, @op4]
    @open_polygon = Geokit::Polygon.new(@open_points)
  end

  def test_point_inside_poly
    # puts "\n\nTesting point inside poly... {@polygon.contains?(@point_inside)}\n\n"
    assert @polygon.contains?(@point_inside)
  end

  def test_point_outside_poly
    # puts "\n\nTesting point outside poly... {@polygon.contains?(@point_outside)}\n\n"
    assert !@polygon.contains?(@point_outside)
  end

  def test_points_inside_complex_poly
    # puts "\n\nTesting points INSIDE complex poly..."
    # puts "\tone: {@complex_polygon.contains?(@complex_inside_one)}"
    # puts "\ttwo: {@complex_polygon.contains?(@complex_inside_two)}"
    # puts "\tthree: {@complex_polygon.contains?(@complex_inside_three)}\n\n"
    assert @complex_polygon.contains?(@complex_inside_one)
    assert @complex_polygon.contains?(@complex_inside_two)
    assert @complex_polygon.contains?(@complex_inside_three)
  end

  def test_points_outside_complex_poly
    # puts "\n\nTesting points OUTSIDE complex poly..."
    # puts "\tone: {@complex_polygon.contains?(@complex_outside_one)}"
    # puts "\ttwo: {@complex_polygon.contains?(@complex_outside_two)}"
    # puts "\tthree: {@complex_polygon.contains?(@complex_outside_three)}\n\n"
    assert !@complex_polygon.contains?(@complex_outside_one)
    assert !@complex_polygon.contains?(@complex_outside_two)
    assert !@complex_polygon.contains?(@complex_outside_three)
  end

  def test_open_polygon
    # A polygon can only exist of the last point is equal to the first
    # Otherwise, it would just be a line of points.

    # puts "\n\nTesting intialize function to close an open polygon..."
    # puts "\t Does poly_x[0] (#{@open_polygon.poly_x[0]}) == poly_x[-1] (#{@open_polygon.poly_x[-1]}) ?"
    # puts "\t Does poly_y[0] (#{@open_polygon.poly_y[0]}) == poly_y[-1] (#{@open_polygon.poly_y[-1]}) ?"

    assert @open_polygon.points[0].lng == @open_polygon.points[-1].lng
    assert @open_polygon.points[0].lat == @open_polygon.points[-1].lat
  end

  def test_centroid_for_simple_poly
    @polygon_centroid = Geokit::LatLng.new(45.27463866133501, -93.41400121829719)
    assert_equal(@polygon.centroid, @polygon_centroid)
  end

  def test_centroid_for_complex_poly
    @complex_polygon_centroid = Geokit::LatLng.new(45.43622702936517, -93.5352210389731)
    assert_equal(@complex_polygon.centroid, @complex_polygon_centroid)
  end

  def test_centroid_for_open_poly
    @open_polygon_centroid = Geokit::LatLng.new(44.95912726688109, -92.7068888186181)
    assert_equal(@open_polygon.centroid, @open_polygon_centroid)
  end
end
