require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::provider_order=[:google,:yahoo,:us]

class MultiGeocoderTest < BaseGeocoderTest #:nodoc: all
  
  def setup
    super
    @failure = Geokit::GeoLoc.new
  end
  
  def test_successful_first
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@address)
  end
  
  def test_failover
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::YahooGeocoder.expects(:geocode).with(@address).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@address)    
  end
  
  def test_double_failover
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::YahooGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::UsGeocoder.expects(:geocode).with(@address).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@address)    
  end
  
  def test_failure
    Geokit::Geocoders::GoogleGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::YahooGeocoder.expects(:geocode).with(@address).returns(@failure)
    Geokit::Geocoders::UsGeocoder.expects(:geocode).with(@address).returns(@failure)
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.geocode(@address)    
  end

  def test_invalid_provider
    temp = Geokit::Geocoders::provider_order
    Geokit::Geocoders.provider_order = [:bogus]
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.geocode(@address)    
    Geokit::Geocoders.provider_order = temp
  end

end