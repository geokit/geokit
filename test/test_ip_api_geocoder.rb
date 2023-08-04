require File.join(File.dirname(__FILE__), 'helper')

class IpApiGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '74.125.237.209'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.last_url
  end

  def test_ip_api_geocode
    url = "http://ip-api.com/json/#{@ip}"
    res = geocode(@ip, :ip_api_geocode)
    assert_url url
    assert_equal res.city, 'Mountain View'
    assert_equal res.state, 'CA'
    assert_equal res.state_name, 'California'
    assert_equal res.zip, '94043'
    assert_equal res.country_code, 'US'
  end

  def test_ip_api_pro_geocode
    geocoder_class.key = 'some_api_key'
    url = "http://pro.ip-api.com/json/#{@ip}?key=some_api_key"
    res = geocode(@ip, :ip_api_pro_geocode)
    assert_url url
    assert_equal res.city, 'Mountain View'
    assert_equal res.state, 'CA'
    assert_equal res.state_name, 'California'
    assert_equal res.zip, '94043'
    assert_equal res.country_code, 'US'
  end
end
