require File.join(File.dirname(__FILE__), 'helper')

# Base class for testing geocoders.
class BaseGeocoderTest < Test::Unit::TestCase #:nodoc: all

  class Geokit::Geocoders::TestGeocoder < Geokit::Geocoders::Geocoder
    def self.do_get(url)
      sleep(2)
    end
  end

  class Geokit::Geocoders::CachedGeocoder < Geokit::Geocoders::Geocoder
    def self.parse_json(hash)
      hash
    end
  end
  class SuperSimpleCache
    def initialize
      @cache = {}
    end
    def write(key, value)
      @cache[key] = value
    end
    def fetch(key)
      @cache[key]
    end
  end

  CACHE_RESULT = '{"name":"json"}'
  CACHE_RESULT_HASH = {"name" => "json"}

  # Defines common test fixtures.
  def setup
    @address = 'San Francisco, CA'
    @full_address = '100 Spear St, San Francisco, CA, 94105-1522, US'
    @full_address_short_zip = '100 Spear St, San Francisco, CA, 94105, US'

    @latlng = Geokit::LatLng.new(37.7742, -122.417068)
    @success = Geokit::GeoLoc.new({:city=>"SAN FRANCISCO", :state=>"CA", :country_code=>"US", :lat=>@latlng.lat, :lng=>@latlng.lng})
    @success.success = true
  end

  def test_timeout_call_web_service
    url = "http://www.anything.com"
    Geokit::Geocoders::request_timeout = 1
    assert_nil Geokit::Geocoders::TestGeocoder.call_geocoder_service(url)
  end

  def test_successful_call_web_service
    url = "http://www.anything.com"
    Geokit::Geocoders::Geocoder.expects(:do_get).with(url).returns("SUCCESS")
    assert_equal "SUCCESS", Geokit::Geocoders::Geocoder.call_geocoder_service(url)
  end

  def test_cache
    success = MockSuccess.new
    success.expects(:body).returns(CACHE_RESULT)
    url = 'http://www.cacheme.com'
    Geokit::Geocoders::CachedGeocoder.expects(:call_geocoder_service).with(url).returns(success)
    Geokit::Geocoders::cache = SuperSimpleCache.new
    assert_equal CACHE_RESULT_HASH, Geokit::Geocoders::CachedGeocoder.process(:json, url)
    assert_equal CACHE_RESULT_HASH, Geokit::Geocoders::CachedGeocoder.process(:json, url)
    Geokit::Geocoders::cache = nil
  end
end
