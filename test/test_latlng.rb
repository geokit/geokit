require 'test/unit'
require 'lib/geokit'

class LatLngTest < Test::Unit::TestCase #:nodoc: all
  
  def setup
    @loc_a = Geokit::LatLng.new(32.918593,-96.958444)
    @loc_e = Geokit::LatLng.new(32.969527,-96.990159)
    @point = Geokit::LatLng.new(@loc_a.lat, @loc_a.lng)
  end
  
  def test_distance_between_same_using_defaults
    assert_equal 0, Geokit::LatLng.distance_between(@loc_a, @loc_a)
    assert_equal 0, @loc_a.distance_to(@loc_a)
  end
  
  def test_distance_between_same_with_miles_and_flat
    assert_equal 0, Geokit::LatLng.distance_between(@loc_a, @loc_a, :units => :miles, :formula => :flat)
    assert_equal 0, @loc_a.distance_to(@loc_a, :units => :miles, :formula => :flat)
  end

  def test_distance_between_same_with_kms_and_flat
    assert_equal 0, Geokit::LatLng.distance_between(@loc_a, @loc_a, :units => :kms, :formula => :flat)
    assert_equal 0, @loc_a.distance_to(@loc_a, :units => :kms, :formula => :flat)
  end
  
  def test_distance_between_same_with_miles_and_sphere
    assert_equal 0, Geokit::LatLng.distance_between(@loc_a, @loc_a, :units => :miles, :formula => :sphere)
    assert_equal 0, @loc_a.distance_to(@loc_a, :units => :miles, :formula => :sphere)
  end
  
  def test_distance_between_same_with_kms_and_sphere
    assert_equal 0, Geokit::LatLng.distance_between(@loc_a, @loc_a, :units => :kms, :formula => :sphere)
    assert_equal 0, @loc_a.distance_to(@loc_a, :units => :kms, :formula => :sphere)
  end
  
  def test_distance_between_diff_using_defaults
    assert_in_delta 3.97, Geokit::LatLng.distance_between(@loc_a, @loc_e), 0.01
    assert_in_delta 3.97, @loc_a.distance_to(@loc_e), 0.01
  end
  
  def test_distance_between_diff_with_miles_and_flat
    assert_in_delta 3.97, Geokit::LatLng.distance_between(@loc_a, @loc_e, :units => :miles, :formula => :flat), 0.2
    assert_in_delta 3.97, @loc_a.distance_to(@loc_e, :units => :miles, :formula => :flat), 0.2
  end

  def test_distance_between_diff_with_kms_and_flat
    assert_in_delta 6.39, Geokit::LatLng.distance_between(@loc_a, @loc_e, :units => :kms, :formula => :flat), 0.4
    assert_in_delta 6.39, @loc_a.distance_to(@loc_e, :units => :kms, :formula => :flat), 0.4
  end
  
  def test_distance_between_diff_with_miles_and_sphere
    assert_in_delta 3.97, Geokit::LatLng.distance_between(@loc_a, @loc_e, :units => :miles, :formula => :sphere), 0.01
    assert_in_delta 3.97, @loc_a.distance_to(@loc_e, :units => :miles, :formula => :sphere), 0.01
  end
  
  def test_distance_between_diff_with_kms_and_sphere
    assert_in_delta 6.39, Geokit::LatLng.distance_between(@loc_a, @loc_e, :units => :kms, :formula => :sphere), 0.01
    assert_in_delta 6.39, @loc_a.distance_to(@loc_e, :units => :kms, :formula => :sphere), 0.01
  end
  
  def test_manually_mixed_in
    assert_equal 0, Geokit::LatLng.distance_between(@point, @point)
    assert_equal 0, @point.distance_to(@point)
    assert_equal 0, @point.distance_to(@loc_a)
    assert_in_delta 3.97, @point.distance_to(@loc_e, :units => :miles, :formula => :flat), 0.2
    assert_in_delta 6.39, @point.distance_to(@loc_e, :units => :kms, :formula => :flat), 0.4
  end
  
  def test_heading_between
    assert_in_delta 332, Geokit::LatLng.heading_between(@loc_a,@loc_e), 0.5
  end

  def test_heading_to
    assert_in_delta 332, @loc_a.heading_to(@loc_e), 0.5
  end  
  
  def test_class_endpoint
    endpoint=Geokit::LatLng.endpoint(@loc_a, 332, 3.97)
    assert_in_delta @loc_e.lat, endpoint.lat, 0.0005
    assert_in_delta @loc_e.lng, endpoint.lng, 0.0005
  end

  def test_instance_endpoint
    endpoint=@loc_a.endpoint(332, 3.97)
    assert_in_delta @loc_e.lat, endpoint.lat, 0.0005
    assert_in_delta @loc_e.lng, endpoint.lng, 0.0005
  end  
  
  def test_midpoint
    midpoint=@loc_a.midpoint_to(@loc_e)
    assert_in_delta 32.944061, midpoint.lat, 0.0005
    assert_in_delta(-96.974296, midpoint.lng, 0.0005)
  end  
  
  def test_normalize
    lat=37.7690
    lng=-122.443
    res=Geokit::LatLng.normalize(lat,lng)
    assert_equal res,Geokit::LatLng.new(lat,lng) 
    res=Geokit::LatLng.normalize("#{lat}, #{lng}")
    assert_equal res,Geokit::LatLng.new(lat,lng) 
    res=Geokit::LatLng.normalize("#{lat} #{lng}")
    assert_equal res,Geokit::LatLng.new(lat,lng)
    res=Geokit::LatLng.normalize("#{lat.to_i} #{lng.to_i}")
    assert_equal res,Geokit::LatLng.new(lat.to_i,lng.to_i)    
    res=Geokit::LatLng.normalize([lat,lng])
    assert_equal res,Geokit::LatLng.new(lat,lng)
  end
    
end