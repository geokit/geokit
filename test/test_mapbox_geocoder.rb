require File.join(File.dirname(__FILE__), "helper")

Geokit::Geocoders::MapboxGeocoder.key = ""

class MapboxGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @address = "1714 14th Street NW, Washington, DC"
    @latlng = Geokit::LatLng.new(38.913175, -77.032458)
    @city = "Washington, DC"
  end

  def test_forward_geocode
    VCR.use_cassette("mapbox_forward_geocode") do
      res = Geokit::Geocoders::MapboxGeocoder.geocode(@address)
      assert_equal 38.913184, res.lat
      assert_equal(-77.031952, res.lng)
      assert_equal "United States", res.country
      assert_equal "District of Columbia", res.state
      assert_equal "20009", res.zip
    end
  end

  def test_reverse_geocode
    VCR.use_cassette("mapbox_reverse_geocode") do
      res = Geokit::Geocoders::MapboxGeocoder.reverse_geocode(@latlng)
      assert_equal "United States", res.country
      assert_equal "District of Columbia", res.state
      assert_equal "20009", res.zip
    end
  end

  def test_city_only
    VCR.use_cassette("mapbox_forward_geocode_city_only") do
      res = Geokit::Geocoders::MapboxGeocoder.geocode(@city)
      assert_equal 38.8951, res.lat
      assert_equal(-77.0364, res.lng)
      assert_equal "United States", res.country
      assert_equal "District of Columbia", res.state
      assert_equal "Washington", res.city
      assert_equal "20004", res.zip
    end
  end
end
