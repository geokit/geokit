require File.join(File.dirname(__FILE__), 'helper')

class FreeGeoIpGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '74.125.237.209'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_free_geo_ip_geocode
    url = "http://freegeoip.net/xml/#{@ip}"
    res = geocode(@ip, :free_geo_ip_geocode)
    assert_url url
    assert_equal res.city, 'Mountain View'
    assert_equal res.state, 'CA'
    assert_equal res.country_code, 'US'
  end
end
