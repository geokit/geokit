require File.join(File.dirname(__FILE__), 'helper')

class MapQuestGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @full_address = '100 Spear St Apt. 5, San Francisco, CA, 94105-1522, US'
    @google_full_hash = {street_address: '100 Spear St Apt. 5', city: 'San Francisco', state: 'CA', zip: '94105', country_code: 'US'}
    @google_city_hash = {city: 'San Francisco', state: 'CA'}

    @google_full_loc = Geokit::GeoLoc.new(@google_full_hash)
    @google_city_loc = Geokit::GeoLoc.new(@google_city_hash)

    @key = @keys['map_quest']['key']
    geocoder_class.key = @key
    @base_url = 'https://www.mapquestapi.com/geocoding/v1'
  end

  def test_map_quest_full_address_with_geo_loc
    url = "#{@base_url}/address?key=#{@key}&location=100+Spear+St+Apt.+5%2C+San+Francisco%2C+CA%2C+94105%2C+US"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@google_full_loc, :map_quest_full)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.7921509, -122.394], res.to_a # slightly dif from yahoo
    assert res.is_us?
    assert_equal '100 Spear St, Apt 5, San Francisco, CA, 94105-1500, US', res.full_address # slightly different from yahoo
    assert_equal 'map_quest', res.provider
  end

  def test_reverse_geocode
    madrid = Geokit::GeoLoc.new
    madrid.lat, madrid.lng = '40.4167413', '-3.7032498'
    url = "#{@base_url}/reverse?key=#{@key}&location=#{madrid.lat},#{madrid.lng}"
    TestHelper.expects(:last_url).with(url)
    res = reverse_geocode(madrid.ll, :map_quest_reverse_madrid)

    assert_equal madrid.lat.to_s.slice(1..5), res.lat.to_s.slice(1..5)
    assert_equal madrid.lng.to_s.slice(1..5), res.lng.to_s.slice(1..5)
    assert_equal 'ES', res.country_code
    assert_equal 'map_quest', res.provider

    assert_equal 'Madrid', res.city
    assert_equal 'Comunidad de Madrid', res.state

    assert_equal nil, res.country
    assert_equal '28014', res.zip
    assert_equal true, res.success
  end
end
