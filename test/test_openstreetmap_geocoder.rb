# encoding: utf-8
require File.join(File.dirname(__FILE__), 'helper')

class OSMGeocoderTest < BaseGeocoderTest #:nodoc: all
  OSM_FULL = <<-EOF.strip
      [{"place_id":"425554497","licence":"Data Copyright OpenStreetMap Contributors, Some Rights Reserved. CC-BY-SA 2.0.","boundingbox":["37.792341","37.792441","-122.394074","-122.393974"],"lat":"37.792391","lon":"-122.394024","display_name":"100, Spear Street, Financial District, San Francisco, California, 94105, United States of America","class":"place","type":"house","address":{"house_number":"100","road":"Spear Street","place":"Financial District","city":"San Francisco","county":"San Francisco","state":"California","postcode":"94105","country":"United States of America","country_code":"us"}}]
  EOF

  OSM_CITY = <<-EOF.strip
      [{"place_id":"1586484","licence":"Data Copyright OpenStreetMap Contributors, Some Rights Reserved. CC-BY-SA 2.0.","osm_type":"node","osm_id":"316944780","boundingbox":["37.7240965271","37.744100341797","-122.40126586914","-122.38125823975"],"lat":"37.7340974","lon":"-122.3912596","display_name":"San Francisco, California, United States of America","class":"place","type":"county","icon":"http://nominatim.openstreetmap.org/images/mapicons/poi_boundary_administrative.p.20.png","address":{"county":"San Francisco","state":"California","country":"United States of America","country_code":"us"}},{"place_id":"42109083","licence":"Data Copyright OpenStreetMap Contributors, Some Rights Reserved. CC-BY-SA 2.0.","osm_type":"way","osm_id":"33090874","boundingbox":["37.6398277282715","37.8230590820312","-123.173828125","-122.935707092285"],"lat":"37.7333682068208","lon":"-123.051926367593","display_name":"San Francisco, Marin, California, United States of America","class":"place","type":"city","icon":"http://nominatim.openstreetmap.org/images/mapicons/poi_place_city.p.20.png","address":{"city":"San Francisco","county":"Marin","state":"California","country":"United States of America","country_code":"us"}},{"place_id":"145970","licence":"Data Copyright OpenStreetMap Contributors, Some Rights Reserved. CC-BY-SA 2.0.","osm_type":"node","osm_id":"26819236","boundingbox":["37.768957366943","37.788961181641","-122.42920471191","-122.40919708252"],"lat":"37.7789601","lon":"-122.419199","display_name":"San Francisco, San Francisco County, California, United States of America, North America","class":"place","type":"city","icon":"http://nominatim.openstreetmap.org/images/mapicons/poi_place_city.p.20.png","address":{"city":"San Francisco","county":"San Francisco County","state":"California","country":"United States of America","country_code":"us","place":"North America"}},{"place_id":"42108900","licence":"Data Copyright OpenStreetMap Contributors, Some Rights Reserved. CC-BY-SA 2.0.","osm_type":"way","osm_id":"33090814","boundingbox":["37.7067184448242","37.9298248291016","-122.612289428711","-122.281776428223"],"lat":"37.7782304646168","lon":"-122.442503042395","display_name":"San Francisco, San Francisco County, California, United States of America","class":"place","type":"city","icon":"http://nominatim.openstreetmap.org/images/mapicons/poi_place_city.p.20.png","address":{"city":"San Francisco","county":"San Francisco County","state":"California","country":"United States of America","country_code":"us"}}]
  EOF

  OSM_REVERSE_MADRID = <<-EOF.strip
      {"place_id":"41067113","licence":"Data Copyright OpenStreetMap Contributors, Some Rights Reserved. CC-BY-SA 2.0.","osm_type":"way","osm_id":"31822457","lat":"40.3787537310091","lon":"-3.70187699287946","display_name":"Línea 3, Calle del Doctor Tolosa Latour, Usera, Madrid, 28026, Spain","address":{"subway":"Línea 3","road":"Calle del Doctor Tolosa Latour","suburb":"Usera","city_district":"Usera","city":"Madrid","county":"Madrid","state":"Madrid","postcode":"28026","country":"Spain","country_code":"es"}}
  EOF

  OSM_REVERSE_PRILEP = <<-EOF.strip
      {"place_id":"46960069","licence":"Data Copyright OpenStreetMap Contributors, Some Rights Reserved. CC-BY-SA 2.0.","osm_type":"way","osm_id":"39757255","lat":"41.3508581896005","lon":"21.549896984439","display_name":"Gimnasium  Mirche Acev, Marksova, Prilep, Macedonia","address":{"school":"Gimnasium  Mirche Acev","road":"Marksova","city":"Prilep","country":"Macedonia","country_code":"mk"}}
  EOF

  def setup
    super
    @osm_full_hash = {street_address: '100 Spear St', city: 'San Francisco', state: 'CA', zip: '94105', country_code: 'US'}
    @osm_city_hash = {city: 'San Francisco', state: 'CA'}
    @osm_full_loc = Geokit::GeoLoc.new(@osm_full_hash)
    @osm_city_loc = Geokit::GeoLoc.new(@osm_city_hash)
  end

  # the testing methods themselves
  def test_osm_full_address
    response = MockSuccess.new
    response.expects(:body).returns(OSM_FULL)
    url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&addressdetails=1&q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_full_address_assertions(Geokit::Geocoders::OSMGeocoder.geocode(@full_address_short_zip))
  end

  def test_osm_full_address_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(OSM_FULL)
    url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&addressdetails=1&q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::OSMGeocoder.geocode(@full_address_short_zip)
    assert_equal 'house', res.accuracy
  end

  def test_osm_full_address_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(OSM_FULL)
    url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&addressdetails=1&q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_full_address_assertions(Geokit::Geocoders::OSMGeocoder.geocode(@osm_full_loc))
  end

  def test_osm_city
    response = MockSuccess.new
    response.expects(:body).returns(OSM_CITY)
    url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&addressdetails=1&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_city_assertions(Geokit::Geocoders::OSMGeocoder.geocode(@address))
  end

  def test_osm_city_with_accept_language
    response = MockSuccess.new
    response.expects(:body).returns(OSM_CITY)
    url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&accept-language=pt-br&addressdetails=1&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_city_assertions(Geokit::Geocoders::OSMGeocoder.geocode(@address, {:'accept-language' => 'pt-br'}))
  end

  def test_osm_city_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(OSM_CITY)
    url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&addressdetails=1&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::OSMGeocoder.geocode(@address)
    assert_equal 'county', res.accuracy
  end

  def test_osm_city_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(OSM_CITY)
    url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&addressdetails=1&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_city_assertions(Geokit::Geocoders::OSMGeocoder.geocode(@osm_city_loc))
  end

  def test_reverse_geo_coding
    response = MockSuccess.new
    response.expects(:body).returns(OSM_REVERSE_PRILEP)
    prilep = Geokit::GeoLoc.new
    prilep.lat, prilep.lng = '41.3527177', '21.5497808'
    url = "http://nominatim.openstreetmap.org/reverse?format=json&addressdetails=1&lat=#{prilep.lat}&lon=#{prilep.lng}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::OSMGeocoder.do_reverse_geocode(prilep.ll)

      # OSM does not return the exast lat lng in response
      # assert_equal prilep.lat.to_s.slice(1..5), res.lat.to_s.slice(1..5)
      # assert_equal prilep.lng.to_s.slice(1..5), res.lng.to_s.slice(1..5)
      assert_equal 'MK', res.country_code
      assert_equal 'osm', res.provider

      assert_equal 'Prilep', res.city
      assert_nil res.state

      assert_equal 'Macedonia', res.country
      assert_nil res.precision
      assert_equal true, res.success

      assert_equal 'Marksova, Prilep, MK', res.full_address
      assert_equal 'Marksova', res.street_address
  end

  def test_reverse_geo_code
    response = MockSuccess.new
    response.expects(:body).returns(OSM_REVERSE_MADRID)
    location = Geokit::GeoLoc.new
    # Madrid
    location.lat, location.lng = '40.4167413', '-3.7032498'
    url = "http://nominatim.openstreetmap.org/reverse?format=json&addressdetails=1&lat=#{location.lat}&lon=#{location.lng}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::OSMGeocoder.do_reverse_geocode(location.ll)

    assert_equal 'ES', res.country_code
    assert_equal 'osm', res.provider

    assert_equal 'Madrid', res.city
    assert_equal 'Madrid', res.state

    assert_equal 'Spain', res.country
    assert_equal true, res.success

    assert_equal 'Calle Del Doctor Tolosa Latour, Usera, Madrid, Madrid, 28026, ES', res.full_address
    assert_equal '28026', res.zip
    assert_equal 'Calle Del Doctor Tolosa Latour', res.street_address
  end

  def test_reverse_geo_code_with_accept_language
    response = MockSuccess.new
    response.expects(:body).returns(OSM_REVERSE_MADRID)
    location = Geokit::GeoLoc.new
    # Madrid
    location.lat, location.lng = '40.4167413', '-3.7032498'
    url = "http://nominatim.openstreetmap.org/reverse?format=json&addressdetails=1&lat=#{location.lat}&lon=#{location.lng}&accept-language=pt-br"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    Geokit::Geocoders::OSMGeocoder.do_reverse_geocode(location.ll, {:'accept-language' => 'pt-br'})
  end

  def test_service_unavailable
    response = MockFailure.new
    url = url = "http://nominatim.openstreetmap.org/search?format=json&polygon=0&addressdetails=1&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::OSMGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::OSMGeocoder.geocode(@osm_city_loc).success
  end

  private

  # next two methods do the assertions for both address-level and city-level lookups
  def do_full_address_assertions(res)
    assert_equal 'California', res.state
    assert_equal 'San Francisco', res.city
    assert_equal '37.792391,-122.394024', res.ll
    assert res.is_us?
    assert_equal 'Spear Street 100, San Francisco, California, 94105, US', res.full_address
    assert_equal 'osm', res.provider
  end

  def do_city_assertions(res)
    assert_equal 'California', res.state
    assert_equal 'San Francisco', res.city
    assert_equal '37.7340974,-122.3912596', res.ll
    assert res.is_us?
    assert_equal 'San Francisco, California, US', res.full_address
    assert_nil res.street_address
    assert_equal 'osm', res.provider
  end
end
