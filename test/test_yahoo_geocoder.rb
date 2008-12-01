require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::yahoo = 'Yahoo'

class YahooGeocoderTest < BaseGeocoderTest #:nodoc: all
    YAHOO_FULL=<<-EOF.strip
  <?xml version="1.0"?>
  <ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:yahoo:maps" xsi:schemaLocation="urn:yahoo:maps http://api.local.yahoo.com/MapsService/V1/GeocodeResponse.xsd"><Result precision="address"><Latitude>37.792406</Latitude><Longitude>-122.39411</Longitude><Address>100 SPEAR ST</Address><City>SAN FRANCISCO</City><State>CA</State><Zip>94105-1522</Zip><Country>US</Country></Result></ResultSet>
  <!-- ws01.search.scd.yahoo.com uncompressed/chunked Mon Jan 29 16:23:43 PST 2007 -->
    EOF

    YAHOO_CITY=<<-EOF.strip
  <?xml version="1.0"?>
  <ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:yahoo:maps" xsi:schemaLocation="urn:yahoo:maps http://api.local.yahoo.com/MapsService/V1/GeocodeResponse.xsd"><Result precision="city"><Latitude>37.7742</Latitude><Longitude>-122.417068</Longitude><Address></Address><City>SAN FRANCISCO</City><State>CA</State><Zip></Zip><Country>US</Country></Result></ResultSet>
  <!-- ws02.search.scd.yahoo.com uncompressed/chunked Mon Jan 29 18:00:28 PST 2007 -->
    EOF
    
  def setup
    super
    @yahoo_full_hash = {:street_address=>"100 Spear St", :city=>"San Francisco", :state=>"CA", :zip=>"94105-1522", :country_code=>"US"}
    @yahoo_city_hash = {:city=>"San Francisco", :state=>"CA"}
    @yahoo_full_loc = Geokit::GeoLoc.new(@yahoo_full_hash)
    @yahoo_city_loc = Geokit::GeoLoc.new(@yahoo_city_hash)
  end
  
  # the testing methods themselves
  def test_yahoo_full_address
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_FULL)
    url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=Yahoo&location=#{CGI.escape(@address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_full_address_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@address))
  end 
  
  def test_yahoo_full_address_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_FULL)
    url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=Yahoo&location=#{CGI.escape(@full_address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_full_address_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_full_loc))
  end  

  def test_yahoo_city
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_CITY)
    url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=Yahoo&location=#{CGI.escape(@address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_city_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@address))
  end
  
  def test_yahoo_city_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_CITY)
    url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=Yahoo&location=#{CGI.escape(@address)}"  
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_city_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_city_loc))
  end  
  
  def test_service_unavailable
    response = MockFailure.new
    url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=Yahoo&location=#{CGI.escape(@address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_city_loc).success
  end  

  private

  # next two methods do the assertions for both address-level and city-level lookups
  def do_full_address_assertions(res)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city
    assert_equal "37.792406,-122.39411", res.ll
    assert res.is_us?
    assert_equal "100 Spear St, San Francisco, CA, 94105-1522, US", res.full_address
    assert_equal "yahoo", res.provider
  end
  
  def do_city_assertions(res)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city 
    assert_equal "37.7742,-122.417068", res.ll
    assert res.is_us?
    assert_equal "San Francisco, CA, US", res.full_address 
    assert_nil res.street_address
    assert_equal "yahoo", res.provider
  end  
end