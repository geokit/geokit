require File.join(File.dirname(__FILE__), 'helper')

Geokit::Geocoders::bing = 'AuWcmtBIoPeOubm9BtcN44hTmWw_wNoJ5NEO2L0RaKrGAUE_nlwciKAqwapdq7k7'

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
    url = "http://dev.virtualearth.net/REST/v1/Locations/#{URI.escape(@full_address)}?key=#{Geokit::Geocoders::bing}&o=xml"
    res = Geokit::Geocoders::BingGeocoder.geocode(@full_address)
    assert_equal "CA", res.state
    assert_equal "San Francisco Co.", res.city
    assert_array_in_delta [37.792332, -122.393791], res.to_a
    assert res.country == 'United States'
    assert_equal "100 Spear St, San Francisco, CA 94105", res.full_address
    assert_equal "bing", res.provider
    assert_url url
    end
  end
end
