require File.join(File.dirname(__FILE__), 'helper')

class MappableTest < Test::Unit::TestCase #:nodoc: all

  def test_math_error_classes
    error_case = 0.49 * 180
    from = Geokit::LatLng.new(error_case, error_case)
    to   = Geokit::LatLng.new(error_case, error_case)
    assert_equal 0.0, Geokit::LatLng.distance_between_sphere(from, to, :kms)
  end

end
