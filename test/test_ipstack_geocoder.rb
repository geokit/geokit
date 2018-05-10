require File.join(File.dirname(__FILE__), 'helper')

class IpstackGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '68.194.36.44'
    geocoder_class.api_key = 'some_api_key'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.last_url
  end

  def test_free_geo_ip_geocode
    url = "http://api.ipstack.com/#{@ip}?access_key=some_api_key"
    res = geocode(@ip, :ipstack_geocode)

    assert_url url
    assert_equal res.city, 'The Bronx'
    assert_equal res.state, 'NY'
    assert_equal res.state_name, 'New York'
    assert_equal res.zip, '10466'
    assert_equal res.country_code, 'US'
    assert_equal res.country, 'United States'
    assert_equal res.success?, true
  end
end
