require File.join(File.dirname(__FILE__), 'helper')

class FreeGeoIpGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '74.125.237.209'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_free_geo_ip_geocode
    VCR.use_cassette('free_geo_ip_geocode') do
      url = "http://freegeoip.net/xml/#{@ip}"
    res = Geokit::Geocoders::FreeGeoIpGeocoder.geocode(@ip)
    assert_url url
    assert_equal res.city, 'Mountain View'
    assert_equal res.state, 'CA'
    assert_equal res.country_code, 'US'
    end
  end
end
