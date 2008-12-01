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

  # Defines common test fixtures.
  def setup
    @address = 'San Francisco, CA'    
    @full_address = '100 Spear St, San Francisco, CA, 94105-1522, US'   
    @full_address_short_zip = '100 Spear St, San Francisco, CA, 94105, US' 
    
    @success = Geokit::GeoLoc.new({:city=>"SAN FRANCISCO", :state=>"CA", :country_code=>"US", :lat=>37.7742, :lng=>-122.417068})
    @success.success = true    
  end  
  
  def test_timeout_call_web_service
    Geokit::Geocoders::Geocoder.class_eval do
      def self.do_get(url)
        sleep(2)
      end
    end
    url = "http://www.anything.com"
    Geokit::Geocoders::timeout = 1
    assert_nil Geokit::Geocoders::Geocoder.call_geocoder_service(url)    
  end
  
  def test_successful_call_web_service
    url = "http://www.anything.com"
    Geokit::Geocoders::Geocoder.expects(:do_get).with(url).returns("SUCCESS")
    assert_equal "SUCCESS", Geokit::Geocoders::Geocoder.call_geocoder_service(url)
  end
  
  def test_find_geocoder_methods
    public_methods = Geokit::Geocoders::Geocoder.public_methods
    assert public_methods.include?("yahoo_geocoder")
    assert public_methods.include?("google_geocoder")
    assert public_methods.include?("ca_geocoder")
    assert public_methods.include?("us_geocoder")
    assert public_methods.include?("multi_geocoder")
    assert public_methods.include?("ip_geocoder")
  end
end