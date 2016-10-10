require File.join(File.dirname(__FILE__), 'helper')

class MapboxGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    geocoder_class.key = ''
    super
    @address = '1714 14th Street NW, Washington, DC'
    @latlng = Geokit::LatLng.new(38.913175, -77.032458)
    @city = 'Washington, DC'
    @state = 'District of Columbia'

    geocoder_class.key = @keys['mapbox']['key']
  end

  def test_forward_geocode
    res = geocode(@address, :mapbox_forward_geocode)
    assert_equal 38.913184, res.lat
    assert_equal(-77.031952, res.lng)
    assert_equal 'United States', res.country
    assert_equal 'District of Columbia', res.state
    assert_equal '20009', res.zip
    assert_equal 'zip', res.precision
  end

  def test_reverse_geocode
    res = reverse_geocode(@latlng, :mapbox_reverse_geocode)
    assert_equal 'United States', res.country
    assert_equal 'District of Columbia', res.state
    assert_equal '20009', res.zip
    assert_equal 'zip', res.precision
  end

  def test_city_only
    res = geocode(@city, :mapbox_forward_geocode_city_only)
    assert_equal 38.895, res.lat
    assert_equal(-77.0366, res.lng)
    assert_equal 'United States', res.country
    assert_equal 'District of Columbia', res.state
    assert_equal 'Washington', res.city
    assert_equal '20004', res.zip
    assert_equal 'zip', res.precision
  end

  def test_state_only
    res = geocode(@state, :mapbox_forward_geocode_state_only)
    assert_equal 38.89657, res.lat
    assert_equal(-76.990661, res.lng)
    assert_equal 'United States', res.country
    assert_equal 'District of Columbia', res.state
    assert_nil res.city
    assert_nil res.zip
    assert_equal 'state', res.precision
  end
end
