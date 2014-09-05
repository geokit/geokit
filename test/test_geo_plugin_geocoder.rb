require File.join(File.dirname(__FILE__), 'helper')

class GeoPluginGeocoderTest < BaseGeocoderTest #:nodoc: all
  IP_SUCCESS = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<geoPlugin>
    <geoplugin_city>Belo Horizonte</geoplugin_city>
    <geoplugin_region>Minas Gerais</geoplugin_region>
    <geoplugin_areaCode>0</geoplugin_areaCode>
    <geoplugin_dmaCode>0</geoplugin_dmaCode>
    <geoplugin_countryCode>BR</geoplugin_countryCode>
    <geoplugin_countryName>Brazil</geoplugin_countryName>
    <geoplugin_continentCode>SA</geoplugin_continentCode>
    <geoplugin_latitude>-19.916700</geoplugin_latitude>
    <geoplugin_longitude>-43.933300</geoplugin_longitude>
    <geoplugin_currencyCode>BRL</geoplugin_currencyCode>
    <geoplugin_currencySymbol>&#82;&#36;</geoplugin_currencySymbol>
    <geoplugin_currencyConverter>2.2575001717</geoplugin_currencyConverter>
</geoPlugin>
    EOF

  def setup
    super
    @ip = '74.125.237.209'
    @success.provider = 'geo_plugin'
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

  def test_successful_lookup
    success = MockSuccess.new
    success.expects(:body).returns(IP_SUCCESS)
    url = 'http://www.geoplugin.net/xml.gp?ip=200.150.38.66'
    Geokit::Geocoders::GeoPluginGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    location = Geokit::Geocoders::GeoPluginGeocoder.geocode('200.150.38.66')
    assert_not_nil location
    assert_equal(-19.916700, location.lat)
    assert_equal(-43.933300, location.lng)
    assert_equal 'Belo Horizonte', location.city
    assert_equal 'Minas Gerais', location.state
    assert_equal 'BR', location.country_code
    assert_equal 'geo_plugin', location.provider
    assert location.success?
  end

  def test_invalid_ip
    location = Geokit::Geocoders::GeoPluginGeocoder.geocode('pixrum')
    assert_not_nil location
    assert !location.success?
  end

  def test_service_unavailable
    failure = MockFailure.new
    url = 'http://www.geoplugin.net/xml.gp?ip=69.10.10.10'
    Geokit::Geocoders::GeoPluginGeocoder.expects(:call_geocoder_service).with(url).returns(failure)
    location = Geokit::Geocoders::GeoPluginGeocoder.geocode('69.10.10.10')
    assert_not_nil location
    assert !location.success?
  end
end
