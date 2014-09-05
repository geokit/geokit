require File.join(File.dirname(__FILE__), 'helper')

class BoundsTest < Test::Unit::TestCase #:nodoc: all
  def setup
    # This is the area in Texas
    @sw = Geokit::LatLng.new(32.91663, -96.982841)
    @ne = Geokit::LatLng.new(32.96302, -96.919495)
    @bounds = Geokit::Bounds.new(@sw, @ne)
    @loc_a = Geokit::LatLng.new(32.918593, -96.958444) # inside bounds
    @loc_b = Geokit::LatLng.new(32.914144, -96.958444) # outside bouds

    # this is a cross-meridan area
    @cross_meridian = Geokit::Bounds.normalize([30, 170], [40, -170])
    @inside_cm = Geokit::LatLng.new(35, 175)
    @inside_cm_2 = Geokit::LatLng.new(35, -175)
    @east_of_cm = Geokit::LatLng.new(35, -165)
    @west_of_cm = Geokit::LatLng.new(35, 165)
  end

  def test_equality
    assert_equal Geokit::Bounds.new(@sw, @ne), Geokit::Bounds.new(@sw, @ne)
  end

  def test_normalize
    res = Geokit::Bounds.normalize(@sw, @ne)
    assert_equal res, Geokit::Bounds.new(@sw, @ne)
    res = Geokit::Bounds.normalize([@sw, @ne])
    assert_equal res, Geokit::Bounds.new(@sw, @ne)
    res = Geokit::Bounds.normalize([@sw.lat, @sw.lng], [@ne.lat, @ne.lng])
    assert_equal res, Geokit::Bounds.new(@sw, @ne)
    res = Geokit::Bounds.normalize([[@sw.lat, @sw.lng], [@ne.lat, @ne.lng]])
    assert_equal res, Geokit::Bounds.new(@sw, @ne)
  end

  def test_point_inside_bounds
    assert @bounds.contains?(@loc_a)
  end

  def test_point_outside_bounds
    assert !@bounds.contains?(@loc_b)
  end

  def test_point_inside_bounds_cross_meridian
    assert @cross_meridian.contains?(@inside_cm)
    assert @cross_meridian.contains?(@inside_cm_2)
  end

  def test_point_outside_bounds_cross_meridian
    assert !@cross_meridian.contains?(@east_of_cm)
    assert !@cross_meridian.contains?(@west_of_cm)
  end

  def test_center
    assert_in_delta 32.939828, @bounds.center.lat, 0.00005
    assert_in_delta(-96.9511763, @bounds.center.lng, 0.00005)
  end

  def test_center_cross_meridian
    assert_in_delta 35.41160, @cross_meridian.center.lat, 0.00005
    assert_in_delta 179.38112, @cross_meridian.center.lng, 0.00005
  end

  def test_creation_from_circle
    bounds = Geokit::Bounds.from_point_and_radius([32.939829, -96.951176], 2.5)
    inside = Geokit::LatLng.new 32.9695270000, -96.9901590000
    outside = Geokit::LatLng.new 32.8951550000, -96.9584440000
    assert bounds.contains?(inside)
    assert !bounds.contains?(outside)
  end

  def test_bounds_to_span
    sw = Geokit::LatLng.new(32, -96)
    ne = Geokit::LatLng.new(40, -70)
    bounds = Geokit::Bounds.new(sw, ne)

    assert_equal Geokit::LatLng.new(8, 26), bounds.to_span
  end

  def test_bounds_to_span_with_bounds_crossing_prime_meridian
    sw = Geokit::LatLng.new(20, -70)
    ne = Geokit::LatLng.new(40, 100)
    bounds = Geokit::Bounds.new(sw, ne)

    assert_equal Geokit::LatLng.new(20, 170), bounds.to_span
  end

  def test_bounds_to_span_with_bounds_crossing_dateline
    sw = Geokit::LatLng.new(20, 100)
    ne = Geokit::LatLng.new(40, -70)
    bounds = Geokit::Bounds.new(sw, ne)

    assert_equal Geokit::LatLng.new(20, 190), bounds.to_span
  end
end
