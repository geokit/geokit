require File.join(File.dirname(__FILE__), "helper")

Geokit::Geocoders::MapboxGeocoder.key = ""

class MapboxGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @address = "1714 14th Street NW, Washington, DC"
    @latlng = Geokit::LatLng.new(38.913175, -77.032458)
    @city = "Washington, DC"
    Geokit::Geocoders::MapboxGeocoder.key = "pk.eyJ1IjoiZ2Vva2l0IiwiYSI6ImNpbm1md3dvdTB6anB0dG0zbW9zd3hlODQifQ.dyskNcYK8DvxyjCO3i7afA"
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
      assert_equal 38.895, res.lat
      assert_equal(-77.0366, res.lng)
      assert_equal "United States", res.country
      assert_equal "District of Columbia", res.state
      assert_equal "Washington", res.city
      assert_equal "20004", res.zip
    end
  end
end
