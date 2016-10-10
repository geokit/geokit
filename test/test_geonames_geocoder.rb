require File.join(File.dirname(__FILE__), 'helper')

class GeonamesGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @city = 'Adelaide'
    geocoder_class.key = 'demo'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_geonames_missing_key
    geocoder_class.key = nil
    exception = assert_raise(Geokit::Geocoders::GeocodeError) do
      geocode(@city)
    end
    assert_equal('Geonames requires a key to use their service.', exception.message)
  end

  def test_geonames_geocode
    url = "http://api.geonames.org/postalCodeSearch?placename=#{@city}&maxRows=10&username=demo"
    res = geocode(@city, :geonames_geocode)
    assert_url url
    assert_equal res.country_code, 'AU'
    assert_equal res.state, 'SA'
    assert_equal res.state_name, 'South Australia'
    assert_equal res.state_code, 'SA'
    assert_equal res.city, 'Adelaide'
  end

  def test_geonames_geocode_premium
    # note this test will not actually return results because a valid premium
    # username is required so we are just testing if the url is correct
    geocoder_class.premium = true
    url = "http://ws.geonames.net/postalCodeSearch?placename=#{@city}&maxRows=10&username=demo"
    geocode(@city, :geonames_geocode_premium)
    assert_url url
  end
end
