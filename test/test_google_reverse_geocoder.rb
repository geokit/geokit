require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::google = 'Google'

class GoogleReverseGeocoderTest < BaseGeocoderTest #:nodoc: all
  
  GOOGLE_REVERSE_FULL=<<-EOF.strip  
  <?xml version="1.0" encoding="UTF-8" ?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>51.457833,7.016685</name><Status><code>200</code><request>geocode</request></Status><Placemark id="p1"><address>Porscheplatz 1, 45127 Essen, Deutschland</address><AddressDetails Accuracy="8" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><CountryName>Deutschland</CountryName><AdministrativeArea><AdministrativeAreaName>Nordrhein-Westfalen</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Essen</SubAdministrativeAreaName><Locality><LocalityName>Essen</LocalityName><DependentLocality><DependentLocalityName>Stadtkern</DependentLocalityName><Thoroughfare><ThoroughfareName>Porscheplatz 1</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>45127</PostalCodeNumber></PostalCode></DependentLocality></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="51.4609805" south="51.4546853" east="7.0198324" west="7.0135372" /></ExtendedData><Point><coordinates>7.0166848,51.4578329,0</coordinates></Point></Placemark><Placemark id="p2"><address>Stadtkern, Essen, Deutschland</address><AddressDetails Accuracy="4" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><CountryName>Deutschland</CountryName><AdministrativeArea><AdministrativeAreaName>Nordrhein-Westfalen</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Essen</SubAdministrativeAreaName><Locality><LocalityName>Essen</LocalityName><DependentLocality><DependentLocalityName>Stadtkern</DependentLocalityName></DependentLocality></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="51.4630710" south="51.4506320" east="7.0193200" west="7.0026170" /></ExtendedData><Point><coordinates>7.0124328,51.4568201,0</coordinates></Point></Placemark><Placemark id="p3"><address>45127 Essen, Deutschland</address><AddressDetails Accuracy="5" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><CountryName>Deutschland</CountryName><AdministrativeArea><AdministrativeAreaName>Nordrhein-Westfalen</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Essen</SubAdministrativeAreaName><Locality><LocalityName>Essen</LocalityName><PostalCode><PostalCodeNumber>45127</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="51.4637808" south="51.4503125" east="7.0231080" west="6.9965454" /></ExtendedData><Point><coordinates>7.0104543,51.4556194,0</coordinates></Point></Placemark><Placemark id="p4"><address>Essen, Deutschland</address><AddressDetails Accuracy="4" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><CountryName>Deutschland</CountryName><AdministrativeArea><AdministrativeAreaName>Nordrhein-Westfalen</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Essen</SubAdministrativeAreaName><Locality><LocalityName>Essen</LocalityName></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="51.5342070" south="51.3475730" east="7.1376530" west="6.8943470" /></ExtendedData><Point><coordinates>7.0147614,51.4580686,0</coordinates></Point></Placemark><Placemark id="p5"><address>Essen, Deutschland</address><AddressDetails Accuracy="3" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><CountryName>Deutschland</CountryName><AdministrativeArea><AdministrativeAreaName>Nordrhein-Westfalen</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Essen</SubAdministrativeAreaName></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="51.5342070" south="51.3475730" east="7.1376530" west="6.8943470" /></ExtendedData><Point><coordinates>7.0461136,51.4508381,0</coordinates></Point></Placemark><Placemark id="p6"><address>Nordrhein-Westfalen, Deutschland</address><AddressDetails Accuracy="2" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><CountryName>Deutschland</CountryName><AdministrativeArea><AdministrativeAreaName>Nordrhein-Westfalen</AdministrativeAreaName></AdministrativeArea></Country></AddressDetails><ExtendedData><LatLonBox north="52.5314170" south="50.3225720" east="9.4615950" west="5.8663566" /></ExtendedData><Point><coordinates>7.6615938,51.4332367,0</coordinates></Point></Placemark><Placemark id="p7"><address>Deutschland</address><AddressDetails Accuracy="1" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><CountryName>Deutschland</CountryName></Country></AddressDetails><ExtendedData><LatLonBox north="55.0568230" south="47.2701270" east="15.0418536" west="5.8663566" /></ExtendedData><Point><coordinates>10.4515260,51.1656910,0</coordinates></Point></Placemark></Response></kml>
  EOF
  
  
  def test_google_full_address
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_REVERSE_FULL)
    
    
    # http://maps.google.com/maps/geo?output=xml&oe=utf-8&ll=51.4578329,7.0166848&key=asdad
    
    # #<Geokit::GeoLoc:0x10ec7ec
    #      @city="Essen",
    #      @country_code="DE",
    #      @full_address="Porscheplatz 1, 45127 Essen, Germany",
    #      @lat=51.4578329,
    #      @lng=7.0166848,
    #      @precision="address",
    #      @provider="google",
    #      @state="Nordrhein-Westfalen",
    #      @street_address="Porscheplatz 1",
    #      @success=true,
    #      @zip="45127">
    #     
    
    
    @latlng = "51.4578329,7.0166848"
    
    url = "http://maps.google.com/maps/geo?ll=#{Geokit::Inflector.url_escape(@latlng)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.reverse_geocode(@latlng) 
    assert_equal "Nordrhein-Westfalen", res.state
    assert_equal "Essen", res.city 
    assert_equal "45127", res.zip
    assert_equal "51.4578329,7.0166848", res.ll # slightly dif from yahoo
    assert res.is_us? == false
    assert_equal "Porscheplatz 1, 45127 Essen, Deutschland", res.full_address #slightly different from yahoo
    assert_equal "google", res.provider
  end
  
  
end