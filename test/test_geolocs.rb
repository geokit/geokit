require 'test/unit'
require 'lib/geokit'

class GeoLocsTest < Test::Unit::TestCase #:nodoc: all
  include Geokit
  
  def setup
    @geolocs = GeoLocs.new(GeoLoc.new(:lat => 5, :lng => 7))
    @geolocs.push GeoLoc.new(:lat => 8, :lng => 9)
  end
  
  def test_it_behaves_as_GeoLoc
    assert_respond_to @geolocs, :lat
    assert_respond_to @geolocs, :lng
  end
  
  def test_it_behaves_as_Array
    assert_equal GeoLoc.new(:lat => 8, :lng => 9), @geolocs[1]
  end
  
  def test_add_geoloc
    gs = GeoLocs.new
    gs.add_geoloc GeoLoc.new(:lat => 8, :lng => 9)
    assert_equal 8, gs.lat
    gs.add_geoloc GeoLoc.new(:lat => 5, :lng => 7)
    assert_equal 8, gs.lat
    assert_equal 2, gs.size
    assert_equal GeoLoc.new(:lat => 5, :lng => 7), gs[1]
  end
end