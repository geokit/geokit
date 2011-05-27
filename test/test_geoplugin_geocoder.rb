# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_base_geocoder')

class IpGeocoderTest < BaseGeocoderTest #:nodoc: all
    
  IP_SUCCESS=<<-EOF
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
    @success.provider = "geoPlugin"
  end    
  
  def test_successful_lookup
    success = MockSuccess.new
    success.expects(:body).returns(IP_SUCCESS)
    url = 'http://www.geoplugin.net/xml.gp?ip=200.150.38.66'
    GeoKit::Geocoders::GeoPluginGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    location = GeoKit::Geocoders::GeoPluginGeocoder.geocode('200.150.38.66')
    assert_not_nil location
    assert_equal(-19.916700, location.lat)
    assert_equal(-43.933300, location.lng)
    assert_equal "Belo Horizonte", location.city
    assert_equal "Minas Gerais", location.state
    assert_equal "BR", location.country_code
    assert_equal "geoPlugin", location.provider
    assert location.success?
  end

  def test_invalid_ip
    location = GeoKit::Geocoders::GeoPluginGeocoder.geocode("pixrum")
    assert_not_nil location
    assert !location.success?
  end
  
  def test_service_unavailable
    failure = MockFailure.new
    url = 'http://www.geoplugin.net/xml.gp?ip=10.10.10.10'
    GeoKit::Geocoders::GeoPluginGeocoder.expects(:call_geocoder_service).with(url).returns(failure)
    location = GeoKit::Geocoders::GeoPluginGeocoder.geocode("10.10.10.10")
    assert_not_nil location
    assert !location.success?
  end  
end
