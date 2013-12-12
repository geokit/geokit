require File.join(File.dirname(__FILE__), 'helper')

class MaxmindGeocoderTest < BaseGeocoderTest #:nodoc: all

  def setup
    super
    @ip = '118.210.47.142'
  end

  def test_ip
    location = mock()
    city = mock()
    ::GeoIP.stubs(:new).with(anything).returns(location)
    location.expects(:city).with(@ip).returns(city)
    city.stubs(:latitude).returns(-34.9287)
    city.stubs(:longitude).returns(138.5986)
    city.stubs(:city_name).returns('Adelaide')
    city.stubs(:region_name).returns('Australia')
    city.stubs(:postal_code).returns('')
    city.stubs(:country_code3).returns('AUS')

    res = Geokit::Geocoders::MaxmindGeocoder.geocode(@ip)
    assert_equal 'Adelaide', res.city
    assert_equal true, res.success
    assert res.city
  end

end
