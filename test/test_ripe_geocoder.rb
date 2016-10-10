require File.join(File.dirname(__FILE__), 'helper')

class RipeGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '74.125.237.209'
    @ip_au = '118.210.24.54'
    @base_url = 'http://stat.ripe.net/data/geoloc/data.json'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_45
    res = geocode('45.45.45.45', :ripe_geocode_45)
    assert !res.success
  end

  def test_ripe_geocode
    url = "#{@base_url}?resource=#{@ip}"
    res = geocode(@ip, :ripe_geocode)
    assert_url url
    assert_equal res.city, 'Mountain View'
    assert_equal res.state, 'CA'
    assert_equal res.state_code, 'CA'
    assert_equal res.country_code, 'US'
  end

  def test_ripe_geocode_au
    url = "#{@base_url}?resource=#{@ip_au}"
    res = geocode(@ip_au, :ripe_geocode_au)
    assert_url url
    assert_equal res.city, 'Adelaide'
    assert_equal res.state, nil
    assert_equal res.state_code, nil
    assert_equal res.country_code, 'AU'
  end
end
