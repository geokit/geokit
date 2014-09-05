require File.join(File.dirname(__FILE__), 'helper')

# Base class for testing geocoders.
class NetAdapterTest < Test::Unit::TestCase #:nodoc: all
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

  RESULT = '{"name":"json"}'
  RESULT_HASH = {'name' => 'json'}

  # Defines common test fixtures.
  def setup
    @url = 'http://www.cacheme.com'
    @address = 'San Francisco, CA'
  end

  def test_cache
    old_adapter = Geokit::Geocoders.net_adapter
    Geokit::Geocoders.net_adapter = Geokit::NetAdapter::Typhoeus
    Typhoeus::Config.cache = SuperSimpleCache
    success = MockSuccess.new
    success.expects(:body).returns(RESULT)
    url = 'http://www.cacheme.com'
    Geokit::NetAdapter::Typhoeus.expects(:do_get).with(@url).returns(success)
    assert_equal RESULT_HASH, Geokit::Geocoders::CachedGeocoder.process(:json, @url)
    Typhoeus::Config.cache = nil
    Geokit::Geocoders.net_adapter = old_adapter
  end
end
