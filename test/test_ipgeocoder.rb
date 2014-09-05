# encoding: utf-8
require File.join(File.dirname(__FILE__), 'helper')

class IpGeocoderTest < BaseGeocoderTest #:nodoc: all
  IP_FAILURE = <<-EOF
    Country: SWITZERLAND (CH)
    City: (Unknown City)
    Latitude:
    Longitude:
    EOF

  IP_SUCCESS = <<-EOF
    Country: UNITED STATES (US)
    City: Sugar Grove, IL
    Latitude: 41.7696
    Longitude: -88.4588
    EOF

  IP_LATIN = <<-EOF
    Country: BRAZIL (BR)
    City: S\xE3o Jos\xE9 do Rio Pr\xEAto\n
    Latitude: -20.8
    Longitude: -49.3833
    EOF

  IP_UNICODED = <<-EOF
    Country: SWEDEN (SE)
    City: Borås
    Latitude: 57.7167
    Longitude: 12.9167
    EOF

  PRIVATE_IPS_TO_TEST = [
    '10.10.10.10',
    '172.16.1.3',
    '172.22.3.42',
    '172.30.254.164',
    '192.168.1.1',
    '0.0.0.0',
    '127.0.0.1',
    '240.3.4.5',
    '225.1.6.55'
  ].freeze

  def setup
    super
    @success.provider = 'ip'
  end

  def test_successful_lookup
    success = MockSuccess.new
    success.expects(:body).returns(IP_SUCCESS)
    url = 'http://api.hostip.info/get_html.php?ip=12.215.42.19&position=true'
    Geokit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    location = Geokit::Geocoders::IpGeocoder.geocode('12.215.42.19')
    assert_not_nil location
    assert_equal 41.7696, location.lat
    assert_equal(-88.4588, location.lng)
    assert_equal 'Sugar Grove', location.city
    assert_equal 'IL', location.state
    assert_equal 'US', location.country_code
    assert_equal 'ip', location.provider
    assert location.success?
  end

  def test_unicoded_lookup
    success = MockSuccess.new
    success.expects(:body).returns(IP_UNICODED)
    url = 'http://api.hostip.info/get_html.php?ip=12.215.42.19&position=true'
    Geokit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    location = Geokit::Geocoders::IpGeocoder.geocode('12.215.42.19')
    assert_not_nil location
    assert_equal 57.7167, location.lat
    assert_equal 12.9167, location.lng
    assert_equal "Bor\303\245s", location.city
    assert_nil location.state
    assert_equal 'SE', location.country_code
    assert_equal 'ip', location.provider
    assert location.success?
  end

  def test_non_unicoded_lookup
    success = MockSuccess.new
    success.stubs(:body).returns(IP_LATIN)
    success.stubs(:[]).with('content-type').returns('text/plain; charset=iso-8859-1')
    url = 'http://api.hostip.info/get_html.php?ip=201.23.177.144&position=true'
    Geokit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    location = Geokit::Geocoders::IpGeocoder.geocode('201.23.177.144')
    assert_not_nil location
    assert_equal -20.8, location.lat
    assert_equal -49.3833, location.lng
    assert_equal 'São José Do Rio Prêto', location.city
    assert_nil location.state
    assert_equal 'BR', location.country_code
    assert_equal 'ip', location.provider
    assert location.success?
  end

  def test_failed_lookup
    failure = MockSuccess.new
    failure.expects(:body).returns(IP_FAILURE)
    url = 'http://api.hostip.info/get_html.php?ip=128.178.0.0&position=true'
    Geokit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(failure)
    location = Geokit::Geocoders::IpGeocoder.geocode('128.178.0.0')
    assert_not_nil location
    assert !location.success?
  end

  def test_private_ips
    Geokit::Geocoders::IpGeocoder.expects(:call_geocoder_service).never
    PRIVATE_IPS_TO_TEST.each do |ip|
      location = Geokit::Geocoders::IpGeocoder.geocode(ip)
      assert_not_nil location
      assert !location.success?
    end
  end

  def test_invalid_ip
    Geokit::Geocoders::IpGeocoder.expects(:call_geocoder_service).never
    location = Geokit::Geocoders::IpGeocoder.geocode('blah')
    assert_not_nil location
    assert !location.success?
  end

  def test_service_unavailable
    failure = MockFailure.new
    url = 'http://api.hostip.info/get_html.php?ip=12.215.42.19&position=true'
    Geokit::Geocoders::IpGeocoder.expects(:call_geocoder_service).with(url).returns(failure)
    location = Geokit::Geocoders::IpGeocoder.geocode('12.215.42.19')
    assert_not_nil location
    assert !location.success?
  end
end
