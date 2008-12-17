require 'test/unit'
require 'lib/geokit'

class GeoLocsTest < Test::Unit::TestCase #:nodoc: all
  include Geokit
  
  def setup
    @geolocs = GeoLocs.new(:lat => 5, :lng => 7)
    @geolocs.push GeoLoc.new(:lat => 8, :lng => 9)
  end
  
  def test_it_is_a_GeoLoc
    assert_respond_to @geolocs, :lat
    assert_respond_to @geolocs, :lng
    assert_equal 5, @geolocs.lat
  end
  
  def test_array_acccess
    assert_equal GeoLoc.new(:lat => 8, :lng => 9), @geolocs[1]
  end
  
  def test_push
    g = GeoLoc.new(:lat => 8, :lng => 9)
    gs = g.to_geolocs
    assert_equal 8, gs.lat
    gs.push GeoLoc.new(:lat => 5, :lng => 7)
    assert_equal 8, gs.lat
    assert_equal 2, gs.size
    assert_equal GeoLoc.new(:lat => 5, :lng => 7), gs[1]
  end
    
  def test_all
    assert_equal [GeoLoc.new(:lat => 5, :lng => 7), GeoLoc.new(:lat => 8, :lng => 9)], @geolocs.all
  end
  
end