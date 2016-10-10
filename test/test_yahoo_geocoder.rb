require File.join(File.dirname(__FILE__), 'helper')

class YahooGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @yahoo_full_hash = {street_address: '100 Spear St', city: 'San Francisco', state: 'CA', zip: '94105-1522', country_code: 'US'}
    @yahoo_city_hash = {city: 'San Francisco', state: 'CA'}
    @yahoo_full_loc = Geokit::GeoLoc.new(@yahoo_full_hash)
    @yahoo_city_loc = Geokit::GeoLoc.new(@yahoo_city_hash)

    key = @keys['yahoo']
    geocoder_class.key = key['key']
    geocoder_class.secret = key['secret']
    @base_url = 'https://yboss.yahooapis.com/geo/placefinder'
  end

  def assert_yahoo_url(expected_url)
    assert_equal expected_url, TestHelper.last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  # the testing methods themselves
  def test_yahoo_full_address
    url = "#{@base_url}?flags=J&q=#{escape(@full_address)}"
    do_full_address_assertions(geocode(@full_address, :yahoo_full))
    assert_yahoo_url url
  end

  def test_yahoo_full_address_accuracy
    url = "#{@base_url}?flags=J&q=#{escape(@full_address)}"
    res = geocode(@full_address, :yahoo_full)
    assert_yahoo_url url
    assert_equal 8, res.accuracy
  end

  def test_yahoo_full_address_with_geo_loc
    url = "#{@base_url}?flags=J&q=#{escape(@full_address)}"
    do_full_address_assertions(geocode(@yahoo_full_loc, :yahoo_full))
    assert_yahoo_url url
  end

  def test_yahoo_city
    url = "#{@base_url}?flags=J&q=#{escape(@address)}"
    do_city_assertions(geocode(@address, :yahoo_city))
    assert_yahoo_url url
  end

  def test_yahoo_city_accuracy
    url = "#{@base_url}?flags=J&q=#{escape(@address)}"
    res = geocode(@address, :yahoo_city)
    assert_yahoo_url url
    assert_equal 4, res.accuracy
  end

  def test_yahoo_city_with_geo_loc
    url = "#{@base_url}?flags=J&q=#{escape(@address)}"
    do_city_assertions(geocode(@yahoo_city_loc, :yahoo_city))
    assert_yahoo_url url
  end

  def test_no_results
    no_results_address = 'ZZ, ZZ, ZZ'
    url = "#{@base_url}?flags=J&q=#{escape(no_results_address)}"
    result = geocode(no_results_address, :yahoo_no_results)
    assert_yahoo_url url
    assert_equal ',', result.ll
  end

  def test_service_unavailable
    response = MockFailure.new
    geocoder_class.expects(:call_geocoder_service).returns(response)
    assert !geocode(@yahoo_city_loc).success
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
