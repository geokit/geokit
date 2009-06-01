require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::ip_provider_order=[:geo_plugin,:ip]

class MultiIpGeocoderTest < BaseGeocoderTest #:nodoc: all
  
  def setup
    @ip_address = '10.10.10.10'
    @success = Geokit::GeoLoc.new({:city=>"SAN FRANCISCO", :state=>"CA", :country_code=>"US", :lat=>37.7742, :lng=>-122.417068})
    @success.success = true
    @failure = Geokit::GeoLoc.new
  end
  
  def test_successful_first
    Geokit::Geocoders::GeoPluginGeocoder.expects(:geocode).with(@ip_address, {}).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@ip_address)
  end
  
  def test_failover
    Geokit::Geocoders::GeoPluginGeocoder.expects(:geocode).with(@ip_address, {}).returns(@failure)
    Geokit::Geocoders::IpGeocoder.expects(:geocode).with(@ip_address, {}).returns(@success)
    assert_equal @success, Geokit::Geocoders::MultiGeocoder.geocode(@ip_address)
  end
  
  def test_failure
    Geokit::Geocoders::GeoPluginGeocoder.expects(:geocode).with(@ip_address, {}).returns(@failure)
    Geokit::Geocoders::IpGeocoder.expects(:geocode).with(@ip_address, {}).returns(@failure)
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.geocode(@ip_address)
  end
  
  def test_invalid_provider
    temp = Geokit::Geocoders::ip_provider_order
    Geokit::Geocoders.ip_provider_order = [:bogus]
    assert_equal @failure, Geokit::Geocoders::MultiGeocoder.geocode(@ip_address)
    Geokit::Geocoders.ip_provider_order = temp
  end

end
