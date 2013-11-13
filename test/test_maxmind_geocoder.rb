require File.join(File.dirname(__FILE__), 'helper')

class MaxmindGeocoderTest < BaseGeocoderTest #:nodoc: all

  def setup
    super
    @ip = '118.210.47.142'
  end

  def test_ip
    VCR.use_cassette('maxmind_ip') do
    res = Geokit::Geocoders::MaxmindGeocoder.geocode(@ip)
    assert_equal 'Adelaide', res.city
    end
  end

end
