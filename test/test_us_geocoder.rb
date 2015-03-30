require File.join(File.dirname(__FILE__), 'helper')

Geokit::Geocoders::UsGeocoder.key = nil

class UsGeocoderTest < BaseGeocoderTest #:nodoc: all
  GEOCODER_US_FULL = '37.792528,-122.393981,100 Spear St,San Francisco,CA,94105'

  def setup
    super
    @us_full_hash = {city: 'San Francisco', state: 'CA'}
    @us_full_loc = Geokit::GeoLoc.new(@us_full_hash)
  end

  def test_geocoder_us
    response = MockSuccess.new
    response.expects(:body).returns(GEOCODER_US_FULL)
    url = "http://geocoder.us/service/csv/geocode?address=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::UsGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    verify(Geokit::Geocoders::UsGeocoder.geocode(@address))
  end

  def test_geocoder_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(GEOCODER_US_FULL)
    url = "http://geocoder.us/service/csv/geocode?address=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::UsGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    verify(Geokit::Geocoders::UsGeocoder.geocode(@us_full_loc))
  end

  def test_service_unavailable
    response = MockFailure.new
    url = "http://geocoder.us/service/csv/geocode?address=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::UsGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::UsGeocoder.geocode(@us_full_loc).success
  end

  def test_all_method
    response = MockSuccess.new
    response.expects(:body).returns(GEOCODER_US_FULL)
    url = "http://geocoder.us/service/csv/geocode?address=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::UsGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::UsGeocoder.geocode(@address)
    assert_equal 1, res.all.size
  end

  private

  def verify(location)
    assert_equal 'CA', location.state
    assert_equal 'San Francisco', location.city
    assert_equal '37.792528,-122.393981', location.ll
    assert location.is_us?
    assert_equal '100 Spear St, San Francisco, CA, 94105, US', location.full_address  # slightly different from yahoo
  end
end
