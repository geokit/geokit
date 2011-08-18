require 'test/unit'
require 'net/http'
require 'rubygems'
require 'mocha'
require 'lib/geokit'

class MockSuccess < Net::HTTPSuccess #:nodoc: all
  def initialize
  end
end

class MockFailure < Net::HTTPServiceUnavailable #:nodoc: all
  def initialize
  end
end

# Base class for testing geocoders.
class BaseGeocoderTest < Test::Unit::TestCase #:nodoc: all

  class Geokit::Geocoders::TestGeocoder < Geokit::Geocoders::Geocoder
    def self.do_get(url)
      sleep(2)
    end    
  end

  # Defines common test fixtures.
  def setup
    @address = 'San Francisco, CA'    
    @full_address = '100 Spear St, San Francisco, CA, 94105-1522, US'   
    @full_address_short_zip = '100 Spear St, San Francisco, CA, 94105, US' 
    
    @latlng = Geokit::LatLng.new(37.7742, -122.417068)
    @success = Geokit::GeoLoc.new({:city=>"SAN FRANCISCO", :state=>"CA", :country_code=>"US", :lat=>@latlng.lat, :lng=>@latlng.lng})
    @success.success = true    
  end  
  
  def test_timeout_call_web_service
    url = "http://www.anything.com"
    Geokit::Geocoders::request_timeout = 1
    assert_nil Geokit::Geocoders::TestGeocoder.call_geocoder_service(url)    
  end
  
  def test_successful_call_web_service
    url = "http://www.anything.com"
    Geokit::Geocoders::Geocoder.expects(:do_get).with(url).returns("SUCCESS")
    assert_equal "SUCCESS", Geokit::Geocoders::Geocoder.call_geocoder_service(url)
  end
  
  def test_successful_call_web_service_with_basic_auth
    user_credentials = 'user1:asdf1234'
    url              = "http://#{user_credentials}@www.anything.com"

    # Expect a Net::HTTP::Get instance to setup basic auth
    http_get_request = Net::HTTP::Get.new(url)
    Net::HTTP::Get.expects(:new).returns(http_get_request)
    http_get_request.expects(:basic_auth).with('user1', 'asdf1234')

    # Expect a Net::HTTP::Proxy to use the http_get_request with basic auth
    mock_http_proxy    = mock('http_proxy')
    mock_proxy_result  = mock('proxy_result')
    mock_proxy_request = mock('proxy_request')
    Net::HTTP.expects(:Proxy).returns(mock_http_proxy)
    mock_http_proxy.expects(:new).with('www.anything.com', 80).returns(mock_proxy_result)
    mock_proxy_result.expects(:start).yields(mock_proxy_request).returns('SUCCESS')
    mock_proxy_request.expects(:request).with(http_get_request)

    assert_equal "SUCCESS", Geokit::Geocoders::Geocoder.call_geocoder_service(url)
  end

  def test_find_geocoder_methods
    public_methods = Geokit::Geocoders::Geocoder.public_methods.map { |m| m.to_s }
    assert public_methods.include?("yahoo_geocoder")
    assert public_methods.include?("google_geocoder")
    assert public_methods.include?("ca_geocoder")
    assert public_methods.include?("us_geocoder")
    assert public_methods.include?("multi_geocoder")
    assert public_methods.include?("ip_geocoder")
  end
end
