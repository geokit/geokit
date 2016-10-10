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

    @key_url  = 'https://maps.googleapis.com/maps/api/geocode/json'
    @base_url = 'https://maps.google.com/maps/api/geocode/json'
  end

  # Example from:
  # https://developers.google.com/maps/documentation/business/webservices#signature_examples
  def test_google_signature
    cryptographic_key = 'vNIXE0xscrmjlyV-12Nj_BvUPaw='
    query_string = '/maps/api/geocode/json?address=New+York&sensor=false&client=clientID'
    signature = geocoder_class.send(:sign_gmap_bus_api_url, query_string, cryptographic_key)
    assert_equal 'KrU1TzVQM7Ur0i8i7K3huiw3MsA=', signature
  end

  # Example from:
  # https://developers.google.com/maps/documentation/business/webservices#signature_examples
  def test_google_signature_and_url
    geocoder_class.client_id = 'clientID'
    geocoder_class.cryptographic_key = 'vNIXE0xscrmjlyV-12Nj_BvUPaw='
    url = geocoder_class.send(:submit_url, 'address=New+York')
    geocoder_class.client_id = nil
    geocoder_class.cryptographic_key = nil
    assert_equal "#{@key_url}?sensor=false&address=New+York&client=clientID&signature=9mevp7SoVsSKzF9nj-vApMYbatg=", url
  end

  def test_google_api_key
    geocoder_class.api_key = 'someKey'
    url = geocoder_class.send(:submit_url, 'address=New+York')
    geocoder_class.api_key = nil
    assert_equal "#{@key_url}?sensor=false&address=New+York&key=someKey", url
  end

  def test_google_insecure_url
    Geokit::Geocoders.secure = false
    url = geocoder_class.send(:submit_url, 'address=New+York')
    Geokit::Geocoders.secure = true
    assert_equal 'http://maps.google.com/maps/api/geocode/json?sensor=false&address=New+York', url
  end

  def test_google_full_address
    url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@address, :google_full_short)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.7749295, -122.4194155], res.to_a # slightly dif from yahoo
    assert res.is_us?
    assert_equal 'San Francisco, CA, USA', res.full_address # slightly different from yahoo
    assert_equal 'google', res.provider
  end

  def test_google_full_address_with_geo_loc
    url = "#{@base_url}?sensor=false&address=#{escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@google_full_loc, :google_full)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_array_in_delta [37.7921509, -122.394], res.to_a # slightly dif from yahoo
    assert res.is_us?
    assert_equal '100 Spear Street #5, San Francisco, CA 94105, USA', res.full_address # slightly different from yahoo
    assert_equal 'google', res.provider
  end

  def test_google_full_address_accuracy
    url = "#{@base_url}?sensor=false&address=#{escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@google_full_loc, :google_full)

    assert_equal 9, res.accuracy
  end

  def test_google_city
    url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@address, :google_city)
    assert_nil res.street_address
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_equal '37.7749295,-122.4194155', res.ll
    assert res.is_us?
    assert_equal 'San Francisco, CA, USA', res.full_address
    assert_equal 'city', res.precision
    assert_equal 'google', res.provider
  end

   def test_google_sublocality
     @address = '682 prospect place Brooklyn ny 11216'
     url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
     TestHelper.expects(:last_url).with(url)
     res = geocode(@address, :google_sublocality)
     assert_equal '682 Prospect Place', res.street_address
     assert_equal 'NY', res.state
     assert_equal 'Brooklyn', res.city
     assert_equal '40.6745812,-73.9541582', res.ll
     assert res.is_us?
     assert_equal '682 Prospect Place, Brooklyn, NY 11216, USA', res.full_address
     assert_equal 'address', res.precision
     assert_equal 'google', res.provider
   end

   def test_google_administrative_area_level_3
     @address = '8 Barkwood Lane, Clifton Park, NY 12065'
     url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
     TestHelper.expects(:last_url).with(url)
     res = geocode(@address, :google_administrative_area_level_3)
     assert_equal '8 Barkwood Lane', res.street_address
     assert_equal 'NY', res.state
     assert_equal 'Clifton Park', res.city
     assert_equal '42.829583,-73.788174', res.ll
     assert res.is_us?
     assert_equal '8 Barkwood Lane, Clifton Park, NY 12065, USA', res.full_address
     assert_equal 'building', res.precision
     assert_equal 'google', res.provider
   end

  def test_google_city_improved_ordering
    res = geocode('62510, fr', :google_city_ordering, bias: 'fr')
    assert_equal 'zip+4', res.precision
    assert_equal '62510 Arques, France', res.full_address
  end

  def test_google_city_accuracy
    url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@address, :google_city)
    assert_equal 'city', res.precision
    assert_equal 4, res.accuracy
  end

  def test_google_city_with_geo_loc
    url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@google_city_loc, :google_city)
    assert_equal 'CA', res.state
    assert_equal 'San Francisco', res.city
    assert_equal '37.7749295,-122.4194155', res.ll
    assert res.is_us?
    assert_equal 'San Francisco, CA, USA', res.full_address
    assert_nil res.street_address
    assert_equal 'city', res.precision
    assert_equal 'google', res.provider
  end

  def test_google_suggested_bounds
    url = "#{@base_url}?sensor=false&address=#{escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@google_full_loc, :google_full)
    assert_instance_of Geokit::Bounds, res.suggested_bounds
    assert_array_in_delta [37.7908019197085, -122.3953489802915], res.suggested_bounds.sw.to_a
    assert_array_in_delta [37.7934998802915, -122.3926510197085], res.suggested_bounds.ne.to_a
  end

  def test_google_suggested_bounds_url
    bounds = Geokit::Bounds.new(
      Geokit::LatLng.new(33.7036917, -118.6681759),
      Geokit::LatLng.new(34.3373061, -118.1552891),
    )
    url = "#{@base_url}?sensor=false&address=Winnetka&bounds=33.7036917%2C-118.6681759%7C34.3373061%2C-118.1552891"
    geocoder_class.expects(:call_geocoder_service).with(url)
    geocode('Winnetka', bias: bounds)
  end

  def test_google_place_id
    url = "#{@base_url}?sensor=false&address=#{escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@full_address_short_zip, :google_full_v3_20)
    assert_equal 'EjExMDAgU3BlYXIgU3RyZWV0ICM1LCBTYW4gRnJhbmNpc2NvLCBDQSA5NDEwNSwgVVNB', res.place_id
  end

  def test_google_formatted_address
    url = "#{@base_url}?sensor=false&address=#{escape(@full_address_short_zip)}"
    TestHelper.expects(:last_url).with(url)
    res = geocode(@full_address_short_zip, :google_full_v3_20)
    assert_equal '100 Spear Street #5, San Francisco, CA 94105, USA', res.formatted_address
  end

  def test_service_unavailable
    response = MockFailure.new
    url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
    geocoder_class.expects(:call_geocoder_service).with(url).returns(response)
    assert !geocode(@google_city_loc).success
  end

  def test_multiple_results
    url = "#{@base_url}?sensor=false&address=#{escape('via Sandro Pertini 8, Ossona, MI')}"
    TestHelper.expects(:last_url).with(url)
    res = geocode('via Sandro Pertini 8, Ossona, MI', :google_multi)
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

  def test_reverse_geocode
    madrid = Geokit::GeoLoc.new
    madrid.lat, madrid.lng = '40.4167413', '-3.7032498'
    url = "#{@base_url}?sensor=false&latlng=#{escape(madrid.ll)}"
    TestHelper.expects(:last_url).with(url)
    res = reverse_geocode(madrid.ll, :google_reverse_madrid)

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

  def test_reverse_geocode_language
    url = "#{@base_url}?sensor=false&latlng=40.416%2C-3.703&language=es"
    TestHelper.expects(:last_url).with(url)
    language_result = reverse_geocode('40.416,-3.703', :google_reverse_madrid_es, language: 'es')

    assert_equal 'ES', language_result.country_code
    assert_equal 'Madrid', language_result.city
  end

  def test_language_response
    url = "#{@base_url}?sensor=false&address=Hanoi&language=FR"
    TestHelper.expects(:last_url).with(url)
    language_result = geocode('Hanoi', :google_language_response_fr, language: 'FR')

    assert_equal 'VN', language_result.country_code
    assert_equal "Hanoï", language_result.city
  end

  def test_too_many_queries
    response = MockSuccess.new
    response.expects(:body).returns '{"status": "OVER_QUERY_LIMIT", "error_message": "quota exceeded!"}'
    url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
    geocoder_class.expects(:call_geocoder_service).with(url).returns(response)
    err = assert_raise Geokit::Geocoders::TooManyQueriesError do
      geocode(@address)
    end
    assert_equal 'quota exceeded!', err.message
  end

  def test_access_denied
    response = MockSuccess.new
    response.expects(:body).returns '{"status": "REQUEST_DENIED", "error_message": "access denied!"}'
    url = "#{@base_url}?sensor=false&address=#{escape(@address)}"
    geocoder_class.expects(:call_geocoder_service).with(url).returns(response)
    err = assert_raise Geokit::Geocoders::AccessDeniedError do
      geocode(@address)
    end
    assert_equal 'access denied!', err.message
  end

  def test_invalid_request
    response = MockSuccess.new
    response.expects(:body).returns '{"results" : [], "status" : "INVALID_REQUEST", "error_message": "error!" }'
    url = "#{@base_url}?sensor=false&address=#{escape("3961 V\u00EDa Marisol")}"
    geocoder_class.expects(:call_geocoder_service).with(url).returns(response)
    err = assert_raise Geokit::Geocoders::GeocodeError do
      geocode("3961 V\u00EDa Marisol")
    end
    assert_equal 'error!', err.message
  end

  def test_country_code_biasing_toledo
    url = "#{@base_url}?sensor=false&address=toledo&region=es"
    TestHelper.expects(:last_url).with(url)
    biased_result = geocode('toledo', :google_country_code_biased_result_toledo, bias: 'es')

    assert_equal 'ES', biased_result.country_code
    assert_equal 'CM', biased_result.state

    url = "#{@base_url}?sensor=false&address=toledo"
    TestHelper.expects(:last_url).with(url)
    biased_result = geocode('toledo', :google_result_toledo_default_bias)

    assert_equal 'US', biased_result.country_code
    assert_equal 'OH', biased_result.state
  end

  def test_country_code_biasing_orly
    url = "#{@base_url}?sensor=false&address=orly&region=fr"
    TestHelper.expects(:last_url).with(url)
    biased_result = geocode('orly', :google_country_code_biased_result_orly, bias: 'fr')

    assert_equal 'FR', biased_result.country_code
    assert_equal 'Orly, France', biased_result.full_address
  end


  def test_component_filtering
    url = 'https://maps.google.com/maps/api/geocode/json?sensor=false&address=austin'
    TestHelper.expects(:last_url).with(url)
    filtered_result = geocode('austin', :test_component_filtering_off)

    assert_equal 'TX', filtered_result.state
    assert_equal 'Austin, TX, USA', filtered_result.full_address

    url = 'https://maps.google.com/maps/api/geocode/json?sensor=false&address=austin&components=administrative_area:il%7Ccountry:us'
    TestHelper.expects(:last_url).with(url)
    filtered_result = geocode('austin',
      :test_component_filtering_on,
      components: { administrative_area: 'IL', country: 'US' })

    assert_equal 'IL', filtered_result.state
    assert_equal 'Austin, Chicago, IL, USA', filtered_result.full_address

    url = 'https://maps.google.com/maps/api/geocode/json?sensor=false&address=austin'
    TestHelper.expects(:last_url).with(url)
    filtered_result = geocode('austin', :test_component_filtering_on_without_filter, components: nil)

    assert_equal 'TX', filtered_result.state
    assert_equal 'Austin, TX, USA', filtered_result.full_address
  end
end
