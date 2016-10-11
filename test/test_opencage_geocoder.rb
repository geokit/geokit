# encoding: utf-8
require File.join(File.dirname(__FILE__), 'helper')

class OpencageGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @opencage_full_hash = {street_address: '100 Spear St', city: 'San Francisco', state: 'CA', zip: '94105', country_code: 'US'}
    @opencage_city_hash = {city: 'San Francisco', state: 'CA'}
    @opencage_full_loc = Geokit::GeoLoc.new(@opencage_full_hash)
    @opencage_city_loc = Geokit::GeoLoc.new(@opencage_city_hash)

    # Note: This is not a real key because having real keys on github
    # is not advised
    key = 'someopencageapikey'
    geocoder_class.key = key
    @base_url = 'https://api.opencagedata.com/geocode/v1/json'
  end

  def test_opencage_full_address
    url = "#{@base_url}?key=someopencageapikey&query=100+Spear+St%2C+San+Francisco%2C+CA%2C+94105%2C+US&no_annotations=1"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@opencage_full_loc, :opencage_full)

    assert_equal 'California', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.7921509, -122.394], res.to_a
    assert res.is_us?
    assert_equal 'Spear Street 100, San Francisco, California, 94103, US', res.full_address
    assert_equal 'opencage', res.provider
  end

  def test_opencage_city
    url = "#{@base_url}?key=someopencageapikey&query=San+Francisco%2C+CA&no_annotations=1"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@opencage_city_loc, :opencage_city)

    assert_equal 'California', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.7792768, -122.4192704], res.to_a
    assert res.is_us?
    assert_equal 'San Francisco, California, US', res.full_address
    assert_equal 'opencage', res.provider
  end

  def test_opencage_reverse
    location = Geokit::GeoLoc.new
    location.lat, location.lng = '40.4167413', '-3.7032498'     # Madrid

    url = "#{@base_url}?key=someopencageapikey&query=40.4167413%2C-3.7032498&no_annotations=1"
    TestHelper.expects(:last_url).with(url)
    res = geocode(location.ll, :opencage_reverse_madrid)

    assert_equal 'ES', res.country_code
    assert_equal 'opencage', res.provider

    assert_equal 'Madrid', res.city
    assert_equal 'Community of Madrid', res.state

    assert_equal 'Spain', res.country
    assert_equal true, res.success

    assert_equal "Calle De Zurbano, Chamberí, Madrid, Community of Madrid, 28036, ES", res.full_address
    assert_equal 28_036, res.zip
    assert_equal 'Calle De Zurbano', res.street_address
  end

  def test_opencage_reverse2
    location = Geokit::GeoLoc.new
    location.lat, location.lng = '41.3527177', '21.5497808'

    url = "#{@base_url}?key=someopencageapikey&query=41.3527177%2C21.5497808&no_annotations=1"
    TestHelper.expects(:last_url).with(url)
    res = geocode(location.ll, :opencage_reverse_prilep)

    assert_equal 'MK', res.country_code
    assert_equal 'opencage', res.provider

    assert_equal 'Prilep', res.city
    assert_equal 'Pelagonia Region', res.state

    assert_equal 'Macedonia', res.country
    assert_equal 10, res.precision
    assert_equal true, res.success

    assert_equal "Прилепски Бранители, Prilep, Pelagonia Region, MK", res.full_address
    assert_equal "Прилепски Бранители", res.street_address
  end

  # check if the results are in Spanish if &language=es
  def test_language_response
    url = "#{@base_url}?key=someopencageapikey&language=es&query=London&no_annotations=1"
    TestHelper.expects(:last_url).with(url)
    language_result = geocode('London', :opencage_language_response_es, language: 'es')

    assert_equal 'Londres', language_result.city
  end
end
