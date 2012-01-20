require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::yahoo = 'Yahoo'

class YahooGeocoderTest < BaseGeocoderTest #:nodoc: all
    YAHOO_FULL=<<-EOF.strip
      {"ResultSet":{"version":"1.0","Error":0,"ErrorMessage":"No error","Locale":"us_US","Quality":87,"Found":1,"Results":[{"quality":87,"latitude":"37.792406","longitude":"-122.39411","offsetlat":"37.792332","offsetlon":"-122.394027","radius":500,"name":"","line1":"100 Spear St","line2":"San Francisco, CA  94105-1522","line3":"","line4":"United States","house":"100","street":"Spear St","xstreet":"","unittype":"","unit":"","postal":"94105-1522","neighborhood":"","city":"San Francisco","county":"San Francisco County","state":"California","country":"United States","countrycode":"US","statecode":"CA","countycode":"","uzip":"94105","hash":"0FA06819B5F53E75","woeid":12797156,"woetype":11}]}}
    EOF

    YAHOO_CITY=<<-EOF.strip
      {"ResultSet":{"version":"1.0","Error":0,"ErrorMessage":"No error","Locale":"us_US","Quality":40,"Found":1,"Results":[{"quality":40,"latitude":"37.7742","longitude":"-122.417068","offsetlat":"37.7742","offsetlon":"-122.417068","radius":10700,"name":"","line1":"","line2":"San Francisco, CA","line3":"","line4":"United States","house":"","street":"","xstreet":"","unittype":"","unit":"","postal":"","neighborhood":"","city":"San Francisco","county":"San Francisco County","state":"California","country":"United States","countrycode":"US","statecode":"CA","countycode":"","uzip":"94102","hash":"","woeid":2487956,"woetype":7}]}}
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
    url = "http://where.yahooapis.com/geocode?flags=J&appid=Yahoo&q=#{Geokit::Inflector.url_escape(@full_address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_full_address_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@full_address))
  end

  def test_yahoo_full_address_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_FULL)
    url = "http://where.yahooapis.com/geocode?flags=J&appid=Yahoo&q=#{Geokit::Inflector.url_escape(@full_address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::YahooGeocoder.geocode(@full_address)
    assert_equal 8, res.accuracy
  end

  def test_yahoo_full_address_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_FULL)
    url = "http://where.yahooapis.com/geocode?flags=J&appid=Yahoo&q=#{Geokit::Inflector.url_escape(@full_address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_full_address_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_full_loc))
  end

  def test_yahoo_city
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_CITY)
    url = "http://where.yahooapis.com/geocode?flags=J&appid=Yahoo&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_city_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@address))
  end

  def test_yahoo_city_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_CITY)
    url = "http://where.yahooapis.com/geocode?flags=J&appid=Yahoo&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::YahooGeocoder.geocode(@address)
    assert_equal 4, res.accuracy
  end

  def test_yahoo_city_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(YAHOO_CITY)
    url = "http://where.yahooapis.com/geocode?flags=J&appid=Yahoo&q=#{Geokit::Inflector.url_escape(@address)}"
    Geokit::Geocoders::YahooGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    do_city_assertions(Geokit::Geocoders::YahooGeocoder.geocode(@yahoo_city_loc))
  end

  def test_service_unavailable
    response = MockFailure.new
    url = "http://where.yahooapis.com/geocode?flags=J&appid=Yahoo&q=#{Geokit::Inflector.url_escape(@address)}"
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
