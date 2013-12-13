require File.join(File.dirname(__FILE__), 'helper')

class GeoPluginGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '74.125.237.209'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_geo_plugin_geocode
    VCR.use_cassette('geo_plugin_geocode') do
    url = "http://www.geoplugin.net/xml.gp?ip=#{@ip}"
    res = Geokit::Geocoders::GeoPluginGeocoder.geocode(@ip)
    assert_url url
    assert_equal res.city, 'Mountain View'
    assert_equal res.state, 'CA'
    assert_equal res.country_code, 'US'
    end
  end
end
