# encoding: utf-8
require File.join(File.dirname(__FILE__), 'test_base_geocoder')

class IpGeocoderTest < BaseGeocoderTest #:nodoc: all
    
  IP_FAILURE=<<-EOF
    Country: (Private Address) (XX)
    City: (Private Address)
    Latitude: 
    Longitude:
    EOF
    
  IP_SUCCESS=<<-EOF
    Country: UNITED STATES (US)
    City: Sugar Grove, IL
    Latitude: 41.7696
    Longitude: -88.4588
    EOF
    
  IP_UNICODED=<<-EOF
    Country: SWEDEN (SE)
    City: Borås
    Latitude: 57.7167
    Longitude: 12.9167
    EOF
    
    def setup
      super
      @success.provider = "hostip"
    end    
  
  def test_successful_lookup
    success = MockSuccess.new
    success.expects(:body).returns(IP_SUCCESS)
    url = 'http://api.hostip.info/get_html.php?ip=12.215.42.19&position=true'
    GeoKit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    location = GeoKit::Geocoders::IpGeocoder.geocode('12.215.42.19')
    assert_not_nil location
    assert_equal 41.7696, location.lat
    assert_equal(-88.4588, location.lng)
    assert_equal "Sugar Grove", location.city
    assert_equal "IL", location.state
    assert_equal "US", location.country_code
    assert_equal "hostip", location.provider
    assert location.success?
  end
  
  def test_unicoded_lookup
    success = MockSuccess.new
    success.expects(:body).returns(IP_UNICODED)
    url = 'http://api.hostip.info/get_html.php?ip=12.215.42.19&position=true'
    GeoKit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    location = GeoKit::Geocoders::IpGeocoder.geocode('12.215.42.19')
    assert_not_nil location
    assert_equal 57.7167, location.lat
    assert_equal 12.9167, location.lng
    assert_equal "Bor\303\245s", location.city
    assert_nil location.state
    assert_equal "SE", location.country_code
    assert_equal "hostip", location.provider
    assert location.success?
  end
  
  def test_failed_lookup
    failure = MockSuccess.new
    failure.expects(:body).returns(IP_FAILURE)
    url = 'http://api.hostip.info/get_html.php?ip=10.10.10.10&position=true'
    GeoKit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(failure)
    location = GeoKit::Geocoders::IpGeocoder.geocode("10.10.10.10")
    assert_not_nil location
    assert !location.success?
  end
  
  def test_invalid_ip
    location = GeoKit::Geocoders::IpGeocoder.geocode("blah")
    assert_not_nil location
    assert !location.success?
  end
  
  def test_service_unavailable
    failure = MockFailure.new
    url = 'http://api.hostip.info/get_html.php?ip=10.10.10.10&position=true'
    GeoKit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(failure)
    location = GeoKit::Geocoders::IpGeocoder.geocode("10.10.10.10")
    assert_not_nil location
    assert !location.success?
  end  
end
