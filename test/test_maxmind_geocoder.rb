require File.join(File.dirname(__FILE__), 'helper')

class MaxmindGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '118.210.47.142'
  end

  def test_ip_from_autralia
    location = mock()
    city = mock()
    ::GeoIP.stubs(:new).with(anything).returns(location)
    location.expects(:city).with(@ip).returns(city)
    city.stubs(:latitude).returns(-34.9287)
    city.stubs(:longitude).returns(138.5986)
    city.stubs(:city_name).returns('Adelaide')
    city.stubs(:region_name).returns('Australia')
    city.stubs(:postal_code).returns('')
    city.stubs(:country_code2).returns('AU')

    res = Geokit::Geocoders::MaxmindGeocoder.geocode(@ip)
    assert_equal 'Adelaide', res.city
    assert_equal 'AU', res.country_code
    assert_equal true, res.success
    assert res.city
  end

  def test_ip_from_south_america
    location = mock()
    city = mock()
    ::GeoIP.stubs(:new).with(anything).returns(location)
    location.expects(:city).with(@ip).returns(city)
    city.stubs(:latitude).returns(-34)
    city.stubs(:longitude).returns(-56)
    city.stubs(:city_name).returns('Canelones')
    city.stubs(:region_name).returns('')
    city.stubs(:postal_code).returns('')
    city.stubs(:country_code2).returns('UR')

    res = Geokit::Geocoders::MaxmindGeocoder.geocode(@ip)
    assert_equal 'Canelones', res.city
    assert_equal 'UR', res.country_code
    assert_equal true, res.success
    assert res.city
  end
end
