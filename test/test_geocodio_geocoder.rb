require File.join(File.dirname(__FILE__), 'helper')

Geokit::Geocoders::GeocodioGeocoder.key = '723d41115152d224fd74727df34727c444537f7'

class GeocodioGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @full_address = '1 Infinite Loop, Cupertino, CA 95014'
    @second_address = '300 Brannan St, San Francisco, CA 94107'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_geocodio_geocode
    VCR.use_cassette('geocodio_geocode') do
      res = Geokit::Geocoders::GeocodioGeocoder.geocode(@full_address)
      url = "http://api.geocod.io/v1/geocode?q=#{Geokit::Inflector.url_escape(@full_address)}&api_key=723d41115152d224fd74727df34727c444537f7"

      assert_url url

      verify(res)
    end
  end

  def verify(location)
    assert_equal location.city, 'Cupertino'
    assert_equal location.zip, '95014'
    assert_equal location.lat, 37.331669
    assert_equal location.lng, -122.03074
  end
end
