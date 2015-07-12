require File.join(File.dirname(__FILE__), "helper")

Geokit::Geocoders::CaGeocoder.key = "SOMEKEYVALUE"

class CaGeocoderTest < BaseGeocoderTest #:nodoc: all
  CA_SUCCESS = <<-EOF
  <?xml version="1.0" encoding="UTF-8" ?>
  <geodata> <latt>49.243086</latt><longt>-123.153684</longt>
  <postal>V6L2J7</postal> <standard> <stnumber>2105</stnumber>
  <staddress>32nd AVE W</staddress><city>Vancouver</city><prov>BC</prov>
  <confidence>0.8</confidence></standard> </geodata>
  EOF

  def setup
    @ca_full_hash = { street_address: "2105 West 32nd Avenue",
                      city: "Vancouver", province: "BC", state: "BC" }
    @ca_full_txt = "2105 West 32nd Avenue Vancouver BC"
  end

  def test_geocoder_with_geo_loc_with_account
    response = MockSuccess.new
    response.expects(:body).returns(CA_SUCCESS)
    url = "http://geocoder.ca/?locate=2105+West+32nd+Avenue+Vancouver+BC&auth=SOMEKEYVALUE&geoit=xml"
    Geokit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    verify(Geokit::Geocoders::CaGeocoder.geocode(@ca_full_txt))
  end

  def test_service_unavailable
    response = MockFailure.new
    url = "http://geocoder.ca/?locate=2105+West+32nd+Avenue+Vancouver+BC&auth=SOMEKEYVALUE&geoit=xml"
    Geokit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::CaGeocoder.geocode(@ca_full_txt).success
  end

  private

  def verify(location)
    assert_equal "BC", location.province
    assert_equal "Vancouver", location.city
    assert_equal "49.243086,-123.153684", location.ll
    assert !location.is_us?
  end
end
