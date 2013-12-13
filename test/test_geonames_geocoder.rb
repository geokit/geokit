require File.join(File.dirname(__FILE__), 'helper')

class GeonamesGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @city = 'Adelaide'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_geonames_geocode
    VCR.use_cassette('geonames_geocode') do
    url = "http://ws.geonames.org/postalCodeSearch?placename=#{@city}&maxRows=10"
    res = Geokit::Geocoders::GeonamesGeocoder.geocode(@city)
    assert_url url
    assert_equal res.country_code, 'AU'
    assert_equal res.state, 'South Australia'
    assert_equal res.city, 'Adelaide'
    end
  end
end
