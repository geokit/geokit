require File.join(File.dirname(__FILE__), 'helper')

Geokit::Geocoders::YahooGeocoder.key = 'dj0yJmk9cXByQVN2WHZmTVhDJmQ9WVdrOVZscG1WVWhOTldrbWNHbzlNakF6TlRJME16UTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD0zNg--'
Geokit::Geocoders::YahooGeocoder.secret = 'SECRET'

class YahooGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @yahoo_full_hash = {street_address: '100 Spear St', city: 'San Francisco', state: 'CA', zip: '94105-1522', country_code: 'US'}
    @yahoo_city_hash = {city: 'San Francisco', state: 'CA'}
    @yahoo_full_loc = Geokit::GeoLoc.new(@yahoo_full_hash)
    @yahoo_city_loc = Geokit::GeoLoc.new(@yahoo_city_hash)
  end

  def assert_yahoo_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  # the testing methods themselves
  def test_yahoo_full_address
    VCR.use_cassette('yahoo_full') do
      url = "https://yboss.yahooapis.com/geo/placefinder?flags=J&q=#{Geokit::Inflector.url_escape(@full_address)}"
    do_full_address_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@full_address))
    assert_yahoo_url url
    end
  end

  def test_yahoo_full_address_accuracy
    VCR.use_cassette('yahoo_full') do
      url = "https://yboss.yahooapis.com/geo/placefinder?flags=J&q=#{Geokit::Inflector.url_escape(@full_address)}"
    res = Geokit::Geocoders::YahooGeocoder.geocode(@full_address)
    assert_yahoo_url url
    assert_equal 8, res.accuracy
    end
  end

  def test_yahoo_full_address_with_geo_loc
    VCR.use_cassette('yahoo_full') do
      url = "https://yboss.yahooapis.com/geo/placefinder?flags=J&q=#{Geokit::Inflector.url_escape(@full_address)}"
    do_full_address_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_full_loc))
    assert_yahoo_url url
    end
  end

  def test_yahoo_city
    VCR.use_cassette('yahoo_city') do
      url = "https://yboss.yahooapis.com/geo/placefinder?flags=J&q=#{Geokit::Inflector.url_escape(@address)}"
    do_city_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@address))
    assert_yahoo_url url
    end
  end

  def test_yahoo_city_accuracy
    VCR.use_cassette('yahoo_city') do
      url = "https://yboss.yahooapis.com/geo/placefinder?flags=J&q=#{Geokit::Inflector.url_escape(@address)}"
    res = Geokit::Geocoders::YahooGeocoder.geocode(@address)
    assert_yahoo_url url
    assert_equal 4, res.accuracy
    end
  end

  def test_yahoo_city_with_geo_loc
    VCR.use_cassette('yahoo_city') do
      url = "https://yboss.yahooapis.com/geo/placefinder?flags=J&q=#{Geokit::Inflector.url_escape(@address)}"
    do_city_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_city_loc))
    assert_yahoo_url url
    end
  end

  def test_no_results
    no_results_address = 'ZZ, ZZ, ZZ'
    no_results_full_hash = {street_address: 'ZZ', city: 'ZZ', state: 'ZZ'}
    no_results_full_loc = Geokit::GeoLoc.new(no_results_full_hash)

    VCR.use_cassette('yahoo_no_results') do
      url = "https://yboss.yahooapis.com/geo/placefinder?flags=J&q=#{Geokit::Inflector.url_escape(no_results_address)}"
    result = Geokit::Geocoders::YahooGeocoder.geocode(no_results_address)
    assert_yahoo_url url
    assert_equal ',', result.ll
    end
  end

  def test_service_unavailable
    response = MockFailure.new
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).returns(response)
    assert !Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_city_loc).success
  end

  private

  # next two methods do the assertions for both address-level and city-level lookups
  def do_full_address_assertions(res)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.792332, -122.393791], res.to_a
    assert res.is_us?
    assert_equal '100 Spear St, San Francisco, CA, 94105-1578, US', res.full_address
    assert_equal 'yahoo', res.provider
  end

  def do_city_assertions(res)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.77713, -122.41964], res.to_a
    assert res.is_us?
    assert_equal 'San Francisco, CA, US', res.full_address
    assert_nil res.street_address
    assert_equal 'yahoo', res.provider
  end
end
