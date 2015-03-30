require File.join(File.dirname(__FILE__), 'helper')

Geokit::Geocoders::MapboxGeocoder.key = ''

class MapboxGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @address = '1714 14th Street NW, Washington, DC'
    @latlng = Geokit::LatLng.new(38.913175, -77.032458)
  end

  def test_forward_geocode
    VCR.use_cassette('mapbox_forward_geocode') do
      res = Geokit::Geocoders::MapboxGeocoder.geocode(@address)
      assert_equal res.lat, 38.899393
      assert_equal res.lng, -76.992695
      assert_equal res.country_code, 'US'
      assert_equal res.state, 'District of Columbia'
      assert_equal res.zip, '20002'
    end
  end

  def test_reverse_geocode
    VCR.use_cassette('mapbox_reverse_geocode') do
      res = Geokit::Geocoders::MapboxGeocoder.reverse_geocode(@latlng)
      assert_equal res.country_code, 'US'
      assert_equal res.state, 'District of Columbia'
      assert_equal res.zip, '20009'
    end
  end
end
