require File.join(File.dirname(__FILE__), 'helper')

class GeobytesGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '12.12.12.12'
  end
  
  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end
  
  def test_geobytes_geocoder
    VCR.use_cassette('geobytes_geocode') do
      url = "http://getcitydetails.geobytes.com/GetCityDetails?fqcn=#{@ip}"
      url = "http://freegeoip.net/xml/#{@ip}"
    res = Geokit::Geocoders::FreeGeoIpGeocoder.geocode(@ip)
    assert_url url
    assert_equal res.city, 'New York'
    assert_equal res.geobytescode, 'NY'
    assert_equal res.geobytesinternet, 'US'
  end
  end
  
end
