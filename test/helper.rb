# encoding: utf-8

begin
  require 'rubygems'
  require 'bundler'
  Bundler.setup
rescue LoadError => e
  puts "Error loading bundler (#{e.message}): \"gem install bundler\" for bundler support."
end

require 'geoip'

if ENV['COVERAGE']
  COVERAGE_THRESHOLD = 95
  require 'simplecov'
  require 'simplecov-rcov'
  require 'coveralls'
  Coveralls.wear!

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/test/'
    add_group 'lib', 'lib'
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    percent = SimpleCov.result.covered_percent
    unless percent >= COVERAGE_THRESHOLD
      puts "Coverage must be above #{COVERAGE_THRESHOLD}%. It is #{'%.2f' % percent}%"
      Kernel.exit(1)
    end
  end
end

require 'test/unit'
require 'mocha/setup'
require 'net/http'

require File.join(File.dirname(__FILE__), '../lib/geokit.rb')

class MockSuccess < Net::HTTPSuccess #:nodoc: all
  def initialize
    @header = {}
  end

  def success? # Typhoeus
    true
  end
end

class MockFailure < Net::HTTPServiceUnavailable #:nodoc: all
  def initialize
    @header = {}
  end
end

class TestHelper
  def self.last_url(url)
    @@url = url
  end
  def self.get_last_url
    @@url
  end
end

Geokit::Geocoders::Geocoder.class_eval do
  class << self
    def call_geocoder_service_for_test(url)
      TestHelper.last_url(url)
      call_geocoder_service_old(url)
    end

    alias call_geocoder_service_old call_geocoder_service
    alias call_geocoder_service call_geocoder_service_for_test
  end
end

def assert_array_in_delta(expected_array, actual_array, delta = 0.001, message = '')
  full_message = build_message(message, "<?> and\n<?> expected to be within\n<?> of each other.\n", expected_array, actual_array, delta)
  assert_block(full_message) do
    expected_array.zip(actual_array).all?{|expected_item, actual_item|
      (expected_item.to_f - actual_item.to_f).abs <= delta.to_f
    }
  end
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  # Yahoo BOSS Ignore changing params
  c.default_cassette_options = {
    match_requests_on: [:method,
      VCR.request_matchers.uri_without_params(
        :oauth_nonce, :oauth_timestamp, :oauth_signature
      )
    ]
  }
end

# Base class for testing geocoders.
class BaseGeocoderTest < Test::Unit::TestCase #:nodoc: all
  class Geokit::Geocoders::TestGeocoder < Geokit::Geocoders::Geocoder
    def self.do_get(url)
      sleep(2)
    end
  end

  # Defines common test fixtures.
  def setup
    Geokit::Geocoders.request_timeout = 10
    @address = 'San Francisco, CA'
    @full_address = '100 Spear St, San Francisco, CA, 94105-1522, US'
    @full_address_short_zip = '100 Spear St, San Francisco, CA, 94105, US'

    @latlng = Geokit::LatLng.new(37.7742, -122.417068)
    @success = Geokit::GeoLoc.new({city: 'SAN FRANCISCO', state: 'CA', country_code: 'US', lat: @latlng.lat, lng: @latlng.lng})
    @success.success = true
  end

  def test_timeout_call_web_service
    url = 'http://www.anything.com'
    Geokit::Geocoders.request_timeout = 1
    assert_nil Geokit::Geocoders::TestGeocoder.call_geocoder_service(url)
  end

  def test_successful_call_web_service
    url = 'http://www.anything.com'
    Geokit::Geocoders::Geocoder.expects(:do_get).with(url).returns('SUCCESS')
    assert_equal 'SUCCESS', Geokit::Geocoders::Geocoder.call_geocoder_service(url)
  end
end
