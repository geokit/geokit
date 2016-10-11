require File.join(File.dirname(__FILE__), 'helper')

class GeocodioGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @full_address = '1 Infinite Loop, Cupertino, CA 95014'
    @second_address = '300 Brannan St, San Francisco, CA 94107'

    geocoder_class.key = @keys['geocodio']['key']
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_geocodio_geocode
    res = geocode(@full_address, :geocodio_geocode)
    url = "http://api.geocod.io/v1/geocode?q=#{escape(@full_address)}&api_key=723d41115152d224fd74727df34727c444537f7"

    assert_url url

    verify(res)
  end

  def verify(location)
    assert_equal location.city, 'Cupertino'
    assert_equal location.zip, '95014'
    assert_equal location.lat, 37.331669
    assert_equal location.lng, -122.03074
  end
end
