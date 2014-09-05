require File.join(File.dirname(__FILE__), 'helper')

Geokit::Geocoders::BingGeocoder.key = 'AuWcmtBIoPeOubm9BtcN44hTmWw_wNoJ5NEO2L0RaKrGAUE_nlwciKAqwapdq7k7'

class BingGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '')
  end

  # the testing methods themselves
  def test_bing_full_address
    VCR.use_cassette('bing_full') do
      key = Geokit::Geocoders::BingGeocoder.key
    url = "https://dev.virtualearth.net/REST/v1/Locations/#{URI.escape(@full_address)}?key=#{key}&o=xml"
    res = Geokit::Geocoders::BingGeocoder.geocode(@full_address)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.792332, -122.393791], res.to_a
    assert res.country == 'United States'
    assert_equal '100 Spear St, San Francisco, CA 94105', res.full_address
    assert_equal 'bing', res.provider
    assert_url url
    end
  end

  def test_bing_full_address_au
    address = '440 King William Street, Adelaide, Australia'
    VCR.use_cassette('bing_full_au') do
      key = Geokit::Geocoders::BingGeocoder.key
    url = "https://dev.virtualearth.net/REST/v1/Locations/#{URI.escape(address)}?key=#{key}&o=xml"
    res = Geokit::Geocoders::BingGeocoder.geocode(address)
    assert_equal 'SA', res.state
    assert_equal 'Adelaide', res.city
    assert_array_in_delta [-34.934582, 138.600784], res.to_a
    assert res.country == 'Australia'
    assert_equal '402-440 King William St, Adelaide, SA 5000', res.full_address
    assert_equal 'Australia', res.country
    assert_equal 'bing', res.provider
    assert_url url
    end
  end

  def test_bing_full_address_de
    address = 'Platz der Republik 1, 11011 Berlin, Germany'
    VCR.use_cassette('bing_full_de') do
      key = Geokit::Geocoders::BingGeocoder.key
    url = "https://dev.virtualearth.net/REST/v1/Locations/#{URI.escape(address)}?key=#{key}&o=xml"
    res = Geokit::Geocoders::BingGeocoder.geocode(address)
    assert_equal 'BE', res.state
    assert_equal 'Berlin', res.city
    assert_array_in_delta [52.518596, 13.375502], res.to_a
    assert res.country == 'Germany'
    assert_equal 'Platz der Republik 1, 10557 Berlin', res.full_address
    assert_equal 'bing', res.provider
    assert_equal 'address', res.precision
    assert_equal 8, res.accuracy
    assert_url url
    end
  end

  def test_bing_country
    address = 'Australia'
    VCR.use_cassette('bing_au') do
      key = Geokit::Geocoders::BingGeocoder.key
    url = "https://dev.virtualearth.net/REST/v1/Locations/#{URI.escape(address)}?key=#{key}&o=xml"
    res = Geokit::Geocoders::BingGeocoder.geocode(address)
    assert_equal nil, res.state
    assert_equal nil, res.city
    assert_array_in_delta [-25.585, 134.504], res.to_a
    assert res.country == 'Australia'
    assert_equal 'Australia', res.full_address
    assert_equal 'bing', res.provider
    assert_equal 'country', res.precision
    assert_equal 8, res.accuracy
    assert_url url
    end
  end
end
