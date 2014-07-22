require File.join(File.dirname(__FILE__), 'helper')

class RipeGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @ip = '74.125.237.209'
    @ip_au = '118.210.24.54'
  end

  def assert_url(expected_url)
    assert_equal expected_url, TestHelper.get_last_url.gsub(/&oauth_[a-z_]+=[a-zA-Z0-9\-. %]+/, '').gsub('%20', '+')
  end

  def test_45
    VCR.use_cassette('ripe_geocode_45') do
      res = Geokit::Geocoders::RipeGeocoder.geocode('45.45.45.45')
      assert !res.success
    end
  end

  def test_ripe_geocode
    VCR.use_cassette('ripe_geocode') do
      url = "http://stat.ripe.net/data/geoloc/data.json?resource=#{@ip}"
      res = Geokit::Geocoders::RipeGeocoder.geocode(@ip)
      assert_url url
      assert_equal res.city, 'Mountain View'
      assert_equal res.state, 'CA'
      assert_equal res.state_code, 'CA'
      assert_equal res.country_code, 'US'
    end
  end

  def test_ripe_geocode_au
    VCR.use_cassette('ripe_geocode_au') do
      url = "http://stat.ripe.net/data/geoloc/data.json?resource=#{@ip_au}"
      res = Geokit::Geocoders::RipeGeocoder.geocode(@ip_au)
      assert_url url
      assert_equal res.city, 'Adelaide'
      assert_equal res.state, nil
      assert_equal res.state_code, nil
      assert_equal res.country_code, 'AU'
    end
  end
end
