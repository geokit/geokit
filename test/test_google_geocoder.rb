# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'helper')

class GoogleGeocoderTest < BaseGeocoderTest #:nodoc: all
  def setup
    super
    @full_address = '100 Spear St Apt. 5, San Francisco, CA, 94105-1522, US'
    @full_address_short_zip = '100 Spear St Apt. 5, San Francisco, CA, 94105, US'
    @google_full_hash = {street_address: '100 Spear St Apt. 5', city: 'San Francisco', state: 'CA', zip: '94105', country_code: 'US'}
    @google_city_hash = {city: 'San Francisco', state: 'CA'}

    @google_full_loc = Geokit::GeoLoc.new(@google_full_hash)
    @google_city_loc = Geokit::GeoLoc.new(@google_city_hash)
  end

  # Example from:
  # https://developers.google.com/maps/documentation/business/webservices#signature_examples
  def test_google_signature
    cryptographic_key = 'vNIXE0xscrmjlyV-12Nj_BvUPaw='
    query_string = '/maps/api/geocode/json?address=New+York&sensor=false&client=clientID'
    signature = Geokit::Geocoders::GoogleGeocoder.send(:sign_gmap_bus_api_url, query_string, cryptographic_key)
    assert_equal 'KrU1TzVQM7Ur0i8i7K3huiw3MsA=', signature
  end

  # Example from:
  # https://developers.google.com/maps/documentation/business/webservices#signature_examples
  def test_google_signature_and_url
    Geokit::Geocoders::GoogleGeocoder.client_id = 'clientID'
    Geokit::Geocoders::GoogleGeocoder.cryptographic_key = 'vNIXE0xscrmjlyV-12Nj_BvUPaw='
    url = Geokit::Geocoders::GoogleGeocoder.send(:submit_url, 'address=New+York')
    Geokit::Geocoders::GoogleGeocoder.client_id = nil
    Geokit::Geocoders::GoogleGeocoder.cryptographic_key = nil
    assert_equal 'https://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=New+York&client=clientID&signature=9mevp7SoVsSKzF9nj-vApMYbatg=', url
  end

  def test_google_api_key
    Geokit::Geocoders::GoogleGeocoder.api_key = 'someKey'
    url = Geokit::Geocoders::GoogleGeocoder.send(:submit_url, 'address=New+York')
    Geokit::Geocoders::GoogleGeocoder.api_key = nil
    assert_equal 'https://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=New+York&key=someKey', url
  end

  def test_google_insecure_url
    Geokit::Geocoders.secure = false
    url = Geokit::Geocoders::GoogleGeocoder.send(:submit_url, 'address=New+York')
    Geokit::Geocoders.secure = true
    assert_equal 'http://maps.google.com/maps/api/geocode/json?sensor=false&address=New+York', url
  end

  def test_google_full_address
    VCR.use_cassette('google_full_short') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.7749295, -122.4194155], res.to_a # slightly dif from yahoo
    assert res.is_us?
    assert_equal 'San Francisco, CA, USA', res.full_address # slightly different from yahoo
    assert_equal 'google', res.provider
    end
  end

  def test_google_full_address_with_geo_loc
    VCR.use_cassette('google_full') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.7921509, -122.394], res.to_a # slightly dif from yahoo
    assert res.is_us?
    assert_equal '100 Spear Street #5, San Francisco, CA 94105, USA', res.full_address # slightly different from yahoo
    assert_equal 'google', res.provider
    end
  end

  def test_google_full_address_accuracy
    VCR.use_cassette('google_full') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)

    assert_equal 9, res.accuracy
    end
  end

  def test_google_city
    VCR.use_cassette('google_city') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.do_geocode(@address)
    assert_nil res.street_address
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_equal '37.7749295,-122.4194155', res.ll
    assert res.is_us?
    assert_equal 'San Francisco, CA, USA', res.full_address
    assert_equal 'google', res.provider
    end
  end

   def test_google_sublocality
     @address = '682 prospect place Brooklyn ny 11216'
     VCR.use_cassette('google_sublocality') do
       url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
     TestHelper.expects(:last_url).with(url)
     res = Geokit::Geocoders::GoogleGeocoder.do_geocode(@address)
     assert_equal '682 Prospect Place', res.street_address
     assert_equal 'NY', res.state
     assert_equal 'Brooklyn', res.city
     assert_equal '40.6745812,-73.9541582', res.ll
     assert res.is_us?
     assert_equal '682 Prospect Place, Brooklyn, NY 11216, USA', res.full_address
     assert_equal 'google', res.provider
     end
   end

  def test_google_city_accuracy
    VCR.use_cassette('google_city') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal 4, res.accuracy
    end
  end

  def test_google_city_with_geo_loc
    VCR.use_cassette('google_city') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@google_city_loc)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_equal '37.7749295,-122.4194155', res.ll
    assert res.is_us?
    assert_equal 'San Francisco, CA, USA', res.full_address
    assert_nil res.street_address
    assert_equal 'google', res.provider
    end
  end

  def test_google_suggested_bounds
    VCR.use_cassette('google_full') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_instance_of Geokit::Bounds, res.suggested_bounds
    assert_array_in_delta [37.7908019197085, -122.3953489802915], res.suggested_bounds.sw.to_a
    assert_array_in_delta [37.7934998802915, -122.3926510197085], res.suggested_bounds.ne.to_a
    end
  end

  def test_google_suggested_bounds_url
    bounds = Geokit::Bounds.new(
      Geokit::LatLng.new(33.7036917, -118.6681759),
      Geokit::LatLng.new(34.3373061, -118.1552891)
    )
    url = 'https://maps.google.com/maps/api/geocode/json?sensor=false&address=Winnetka&bounds=33.7036917%2C-118.6681759%7C34.3373061%2C-118.1552891'
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url)
    Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka', bias: bounds)
  end

  def test_service_unavailable
    response = MockFailure.new
    url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::GoogleGeocoder.geocode(@google_city_loc).success
  end

  def test_multiple_results
    VCR.use_cassette('google_multi') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape('via Sandro Pertini 8, Ossona, MI')}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.geocode('via Sandro Pertini 8, Ossona, MI')
    assert_equal 5, res.all.size
    res = res.all[0]
    assert_equal 'Lombardy', res.state
    assert_equal 'Mesero', res.city
    assert_array_in_delta [45.4966218, 8.852694], res.to_a
    assert !res.is_us?
    assert_equal 'Via Sandro Pertini, 8, 20010 Mesero Milan, Italy', res.full_address
    assert_equal '8 Via Sandro Pertini', res.street_address
    assert_equal 'google', res.provider

    res = res.all[4]
    assert_equal 'Lombardy', res.state
    assert_equal 'Ossona', res.city
    assert_array_in_delta [45.5074444, 8.90232], res.to_a
    assert !res.is_us?
    assert_equal 'Via S. Pertini, 20010 Ossona Milan, Italy', res.full_address
    assert_equal 'Via S. Pertini', res.street_address
    assert_equal 'google', res.provider
    end
  end

  def test_reverse_geocode
    VCR.use_cassette('google_reverse_madrid') do
      madrid = Geokit::GeoLoc.new
    madrid.lat, madrid.lng = '40.4167413', '-3.7032498'
    url = "https://maps.google.com/maps/api/geocode/json?sensor=false&latlng=#{Geokit::Inflector.url_escape(madrid.ll)}"
    TestHelper.expects(:last_url).with(url)
    res = Geokit::Geocoders::GoogleGeocoder.do_reverse_geocode(madrid.ll)

    assert_equal madrid.lat.to_s.slice(1..5), res.lat.to_s.slice(1..5)
    assert_equal madrid.lng.to_s.slice(1..5), res.lng.to_s.slice(1..5)
    assert_equal 'ES', res.country_code
    assert_equal 'google', res.provider

    assert_equal 'Madrid', res.city
    assert_equal 'Community of Madrid', res.state

    assert_equal 'Spain', res.country
    assert_equal '28013', res.zip
    assert_equal true, res.success
    end
  end

  def test_reverse_geocode_language
    VCR.use_cassette('google_reverse_madrid_es') do
      url = 'https://maps.google.com/maps/api/geocode/json?sensor=false&latlng=40.416%2C-3.703&language=es'
    TestHelper.expects(:last_url).with(url)
    language_result = Geokit::Geocoders::GoogleGeocoder.reverse_geocode('40.416,-3.703', language: 'es')

    assert_equal 'ES', language_result.country_code
    assert_equal 'Madrid', language_result.city
    end
  end

  def test_language_response
    VCR.use_cassette('google_language_response_fr') do
      url = 'https://maps.google.com/maps/api/geocode/json?sensor=false&address=Hanoi&language=FR'
    TestHelper.expects(:last_url).with(url)
    language_result = Geokit::Geocoders::GoogleGeocoder.geocode('Hanoi', language: 'FR')

    assert_equal 'VN', language_result.country_code
    assert_equal 'Hanoï', language_result.city
    end
  end

  def test_too_many_queries
    response = MockSuccess.new
    response.expects(:body).returns %q/{"status": "OVER_QUERY_LIMIT"}/
    url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert_raise Geokit::Geocoders::TooManyQueriesError do
      res = Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    end
  end

  def test_invalid_request
    response = MockSuccess.new
    response.expects(:body).returns %q/{"results" : [], "status" : "INVALID_REQUEST"}/
    url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector.url_escape("3961 V\u00EDa Marisol")}"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert_raise Geokit::Geocoders::GeocodeError do
      Geokit::Geocoders::GoogleGeocoder.geocode("3961 V\u00EDa Marisol")
    end
  end

  def test_country_code_biasing_toledo
    VCR.use_cassette('google_country_code_biased_result_toledo') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=toledo&region=es"
      TestHelper.expects(:last_url).with(url)
      biased_result = Geokit::Geocoders::GoogleGeocoder.geocode('toledo', :bias => 'es')

      assert_equal 'ES', biased_result.country_code
      assert_equal 'CM', biased_result.state
    end

    VCR.use_cassette('google_result_toledo_default_bias') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=toledo"
      TestHelper.expects(:last_url).with(url)
      biased_result = Geokit::Geocoders::GoogleGeocoder.geocode('toledo')

      assert_equal 'US', biased_result.country_code
      assert_equal 'OH', biased_result.state
    end
  end

  def test_country_code_biasing_orly
    VCR.use_cassette('google_country_code_biased_result_orly') do
      url = "https://maps.google.com/maps/api/geocode/json?sensor=false&address=orly&region=fr"
      TestHelper.expects(:last_url).with(url)
      biased_result = Geokit::Geocoders::GoogleGeocoder.geocode('orly', :bias => 'fr')

      assert_equal 'FR', biased_result.country_code
      assert_equal 'Orly, France', biased_result.full_address
    end
  end

end
