require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::google = 'Google'

class GoogleGeocoderTest < BaseGeocoderTest #:nodoc: all
  
  GOOGLE_FULL=<<-EOF.strip
  <?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>100 spear st, san francisco, ca</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>100 Spear St, San Francisco, CA 94105, USA</address><AddressDetails Accuracy="8" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>US</CountryNameCode><AdministrativeArea><AdministrativeAreaName>CA</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>San Francisco</SubAdministrativeAreaName><Locality><LocalityName>San Francisco</LocalityName><Thoroughfare><ThoroughfareName>100 Spear St</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>94105</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><Point><coordinates>-122.393985,37.792501,0</coordinates></Point></Placemark></Response></kml>
  EOF
  
  GOOGLE_RESULT_WITH_SUGGESTED_BOUNDS=<<-EOF.strip
  <?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>100 spear st, san francisco, ca</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>100 Spear St, San Francisco, CA 94105, USA</address><AddressDetails Accuracy="8" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>US</CountryNameCode><AdministrativeArea><AdministrativeAreaName>CA</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>San Francisco</SubAdministrativeAreaName><Locality><LocalityName>San Francisco</LocalityName><Thoroughfare><ThoroughfareName>100 Spear St</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>94105</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="37.7956328" south="37.7893376" east="-122.3908573" west="-122.3971525" /></ExtendedData><Point><coordinates>-122.393985,37.792501,0</coordinates></Point></Placemark></Response></kml>
  EOF

  GOOGLE_CITY=<<-EOF.strip
  <?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>San Francisco</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>San Francisco, CA, USA</address><AddressDetails Accuracy="4" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>US</CountryNameCode><AdministrativeArea><AdministrativeAreaName>CA</AdministrativeAreaName><Locality><LocalityName>San Francisco</LocalityName></Locality></AdministrativeArea></Country></AddressDetails><Point><coordinates>-122.418333,37.775000,0</coordinates></Point></Placemark></Response></kml>
  EOF
  
  GOOGLE_MULTI="<?xml version='1.0' encoding='UTF-8'?>\n<kml xmlns='http://earth.google.com/kml/2.0'><Response>\n  <name>via Sandro Pertini 8, Ossona, MI</name>\n  <Status>\n    <code>200</code>\n    <request>geocode</request>\n  </Status>\n  <Placemark id='p1'>\n    <address>Via Sandro Pertini, 8, 20010 Mesero MI, Italy</address>\n    <AddressDetails Accuracy='8' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>IT</CountryNameCode><CountryName>Italy</CountryName><AdministrativeArea><AdministrativeAreaName>Lombardy</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Milan</SubAdministrativeAreaName><Locality><LocalityName>Mesero</LocalityName><Thoroughfare><ThoroughfareName>8 Via Sandro Pertini</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>20010</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails>\n    <Point><coordinates>8.8527131,45.4966243,0</coordinates></Point>\n  </Placemark>\n  <Placemark id='p2'>\n    <address>Via Sandro Pertini, 20010 Ossona MI, Italy</address>\n    <AddressDetails Accuracy='6' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>IT</CountryNameCode><CountryName>Italy</CountryName><AdministrativeArea><AdministrativeAreaName>Lombardy</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Milan</SubAdministrativeAreaName><Locality><LocalityName>Ossona</LocalityName><Thoroughfare><ThoroughfareName>Via Sandro Pertini</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>20010</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails>\n    <Point><coordinates>8.9023200,45.5074444,0</coordinates></Point>\n  </Placemark>\n</Response></kml>\n"
  
  GOOGLE_REVERSE_MADRID="<?xml version='1.0' encoding='UTF-8' ?><kml xmlns='http://earth.google.com/kml/2.0'><Response><name>40.416741,-3.703250</name><Status><code>200</code><request>geocode</request></Status><Placemark id='p1'><address>Plaza de la Puerta del Sol, 28013, Madrid, Spain</address><AddressDetails Accuracy='6' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>ES</CountryNameCode><CountryName>Spain</CountryName><AdministrativeArea><AdministrativeAreaName>Madrid</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Madrid</SubAdministrativeAreaName><Locality><LocalityName>Madrid</LocalityName><Thoroughfare><ThoroughfareName>Plaza de la Puerta del Sol</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>28013</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north='40.4199522' south='40.4136570' east='-3.7001138' west='-3.7064091' /></ExtendedData><Point><coordinates>-3.7032537,40.4168023,0</coordinates></Point></Placemark><Placemark id='p2'><address>28013, Madrid, Spain</address><AddressDetails Accuracy='5' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>ES</CountryNameCode><CountryName>Spain</CountryName><AdministrativeArea><AdministrativeAreaName>Madrid</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Madrid</SubAdministrativeAreaName><Locality><LocalityName>Madrid</LocalityName><PostalCode><PostalCodeNumber>28013</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north='40.4244113' south='40.4142840' east='-3.6969862' west='-3.7224820' /></ExtendedData><Point><coordinates>-3.7117806,40.4189645,0</coordinates></Point></Placemark><Placemark id='p3'><address>Madrid, Spain</address><AddressDetails Accuracy='4' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>ES</CountryNameCode><CountryName>Spain</CountryName><AdministrativeArea><AdministrativeAreaName>Madrid</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Madrid</SubAdministrativeAreaName><Locality><LocalityName>Madrid</LocalityName></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north='40.6435181' south='40.3120713' east='-3.5180102' west='-3.8890049' /></ExtendedData><Point><coordinates>-3.7032498,40.4167413,0</coordinates></Point></Placemark><Placemark id='p4'><address>Madrid, Spain</address><AddressDetails Accuracy='2' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>ES</CountryNameCode><CountryName>Spain</CountryName><AdministrativeArea><AdministrativeAreaName>Madrid</AdministrativeAreaName></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north='41.1649106' south='39.8845366' east='-3.0531322' west='-4.5791745' /></ExtendedData><Point><coordinates>-3.5812692,40.4167088,0</coordinates></Point></Placemark><Placemark id='p5'><address>Madrid, Spain</address><AddressDetails Accuracy='3' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>ES</CountryNameCode><CountryName>Spain</CountryName><AdministrativeArea><AdministrativeAreaName>Madrid</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Madrid</SubAdministrativeAreaName></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north='41.1649106' south='39.8845366' east='-3.0531322' west='-4.5791745' /></ExtendedData><Point><coordinates>-3.5812692,40.4167088,0</coordinates></Point></Placemark><Placemark id='p6'><address>Spain</address><AddressDetails Accuracy='1' xmlns='urn:oasis:names:tc:ciq:xsdschema:xAL:2.0'><Country><CountryNameCode>ES</CountryNameCode><CountryName>Spain</CountryName></Country></AddressDetails><ExtendedData><LatLonBox north='43.7903881' south='27.6377504' east='4.3279851' west='-18.1606948' /></ExtendedData><Point><coordinates>-3.7492200,40.4636670,0</coordinates></Point></Placemark></Response></kml>"
   
  GOOGLE_COUNTRY_CODE_BIASED_RESULT = <<-EOF.strip
  <?xml version="1.0" encoding="UTF-8" ?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>Syracuse</name><Status><code>200</code><request>geocode</request></Status><Placemark id="p1"><address>Syracuse, Italy</address><AddressDetails Accuracy="3" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>IT</CountryNameCode><CountryName>Italy</CountryName><AdministrativeArea><AdministrativeAreaName>Sicily</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Syracuse</SubAdministrativeAreaName></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="37.4125978" south="36.6441736" east="15.3367367" west="14.7724913" /></ExtendedData><Point><coordinates>14.9856176,37.0630218,0</coordinates></Point></Placemark></Response></kml>
  EOF
  
  GOOGLE_BOUNDS_BIASED_RESULT = <<-EOF.strip
  <?xml version="1.0" encoding="UTF-8" ?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>Winnetka</name><Status><code>200</code><request>geocode</request></Status><Placemark id="p1"><address>Winnetka, California, USA</address><AddressDetails Accuracy="4" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>US</CountryNameCode><CountryName>USA</CountryName><AdministrativeArea><AdministrativeAreaName>CA</AdministrativeAreaName><AddressLine>Winnetka</AddressLine></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="34.2353090" south="34.1791050" east="-118.5534191" west="-118.5883200" /></ExtendedData><Point><coordinates>-118.5710220,34.2131710,0</coordinates></Point></Placemark></Response></kml>
  EOF

  GOOGLE_TOO_MANY=<<-EOF.strip
  <?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>100 spear st, san francisco, ca</name><Status><code>620</code><request>geocode</request></Status></Response></kml>
  EOF
  
  def setup
    super
    @google_full_hash = {:street_address=>"100 Spear St", :city=>"San Francisco", :state=>"CA", :zip=>"94105", :country_code=>"US"}
    @google_city_hash = {:city=>"San Francisco", :state=>"CA"}

    @google_full_loc = Geokit::GeoLoc.new(@google_full_hash)
    @google_city_loc = Geokit::GeoLoc.new(@google_city_hash)
  end  

  def test_google_full_address
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city 
    assert_equal "37.792501,-122.393985", res.ll # slightly dif from yahoo
    assert res.is_us?
    assert_equal "100 Spear St, San Francisco, CA 94105, USA", res.full_address #slightly different from yahoo
    assert_equal "google", res.provider
  end
  
  def test_google_full_address_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city 
    assert_equal "37.792501,-122.393985", res.ll # slightly dif from yahoo
    assert res.is_us?
    assert_equal "100 Spear St, San Francisco, CA 94105, USA", res.full_address #slightly different from yahoo
    assert_equal "google", res.provider
  end  
  
  def test_google_full_address_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_equal 8, res.accuracy
  end

  def test_google_city
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city
    assert_equal "37.775,-122.418333", res.ll
    assert res.is_us?
    assert_equal "San Francisco, CA, USA", res.full_address
    assert_nil res.street_address
    assert_equal "google", res.provider
  end  
  
  def test_google_city_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal 4, res.accuracy
  end
  
  def test_google_city_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_city_loc)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city
    assert_equal "37.775,-122.418333", res.ll
    assert res.is_us?
    assert_equal "San Francisco, CA, USA", res.full_address
    assert_nil res.street_address
    assert_equal "google", res.provider
  end  
  
  def test_google_suggested_bounds
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_RESULT_WITH_SUGGESTED_BOUNDS)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    
    assert_instance_of Geokit::Bounds, res.suggested_bounds
    assert_equal Geokit::Bounds.new(Geokit::LatLng.new(37.7893376, -122.3971525), Geokit::LatLng.new(37.7956328, -122.3908573)), res.suggested_bounds
  end
  
  def test_service_unavailable
    response = MockFailure.new
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::GoogleGeocoder.geocode(@google_city_loc).success
  end 
  
  def test_multiple_results
    #Geokit::Geocoders::GoogleGeocoder.do_geocode('via Sandro Pertini 8, Ossona, MI')
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_MULTI)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape('via Sandro Pertini 8, Ossona, MI')}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode('via Sandro Pertini 8, Ossona, MI')
    assert_equal "Lombardy", res.state
    assert_equal "Mesero", res.city
    assert_equal "45.4966243,8.8527131", res.ll
    assert !res.is_us?
    assert_equal "Via Sandro Pertini, 8, 20010 Mesero MI, Italy", res.full_address
    assert_equal "8 Via Sandro Pertini", res.street_address
    assert_equal "google", res.provider

    assert_equal 2, res.all.size
    res = res.all[1]
    assert_equal "Lombardy", res.state
    assert_equal "Ossona", res.city
    assert_equal "45.5074444,8.90232", res.ll
    assert !res.is_us?
    assert_equal "Via Sandro Pertini, 20010 Ossona MI, Italy", res.full_address
    assert_equal "Via Sandro Pertini", res.street_address
    assert_equal "google", res.provider
  end

  def test_reverse_geocode
    #Geokit::Geocoders::GoogleGeocoder.do_reverse_geocode("40.4167413, -3.7032498")
    madrid = Geokit::GeoLoc.new
    madrid.lat, madrid.lng = "40.4167413", "-3.7032498"
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_REVERSE_MADRID)
    url = "http://maps.google.com/maps/geo?ll=#{Geokit::Inflector::url_escape(madrid.ll)}&output=xml&key=#{Geokit::Geocoders::google}&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).
      returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.do_reverse_geocode(madrid.ll)

    assert_equal madrid.lat.to_s.slice(1..5), res.lat.to_s.slice(1..5)
    assert_equal madrid.lng.to_s.slice(1..5), res.lng.to_s.slice(1..5)
    assert_equal "ES", res.country_code
    assert_equal "google", res.provider

    assert_equal "Madrid", res.city
    assert_equal "Madrid", res.state

    assert_equal "Spain", res.country
    assert_equal "zip+4", res.precision
    assert_equal true, res.success

    assert_equal "Plaza de la Puerta del Sol, 28013, Madrid, Spain", res.full_address
    assert_equal "28013", res.zip
    assert_equal "Plaza de la Puerta del Sol", res.street_address
  end  
  
  def test_country_code_biasing
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_COUNTRY_CODE_BIASED_RESULT)
    
    url = "http://maps.google.com/maps/geo?q=Syracuse&output=xml&gl=it&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    biased_result = Geokit::Geocoders::GoogleGeocoder.geocode('Syracuse', :bias => 'it')
    
    assert_equal 'IT', biased_result.country_code
    assert_equal 'Sicily', biased_result.state
  end
  
  def test_bounds_biasing
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_BOUNDS_BIASED_RESULT)
    
    url = "http://maps.google.com/maps/geo?q=Winnetka&output=xml&ll=34.197693208849,-118.547160027785&spn=0.247047999999999,0.294914000000006&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    
    bounds = Geokit::Bounds.normalize([34.074081, -118.694401], [34.321129, -118.399487])
    biased_result = Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka', :bias => bounds)
    
    assert_equal 'US', biased_result.country_code
    assert_equal 'CA', biased_result.state
  end

  def test_too_many_queries
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_TOO_MANY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert_raise Geokit::TooManyQueriesError do
      res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    end
  end
end
