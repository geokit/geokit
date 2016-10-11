# encoding: utf-8

begin
  require 'rubygems'
  require 'bundler'
  Bundler.setup
rescue LoadError => e
  puts "Error loading bundler (#{e.message}): \"gem install bundler\" for bundler support."
end

require 'geoip'

require 'coverage_loader'
require 'vcr_loader'
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
  def self.last_url(url = nil)
    if url
      @@url = url
    else
      @@url
    end
  end
end

Geokit::Geocoders::Geocoder.class_eval do
  class << self
    def call_geocoder_service_for_test(url)
      TestHelper.last_url(url)
      call_geocoder_service_old(url)
    end

    alias_method :call_geocoder_service_old, :call_geocoder_service
    alias_method :call_geocoder_service, :call_geocoder_service_for_test
  end
end

def assert_array_in_delta(expected_array, actual_array, delta = 0.001, message = '')
  full_message = build_message(message, "<?> and\n<?> expected to be within\n<?> of each other.\n", expected_array, actual_array, delta)
  assert_block(full_message) do
    expected_array.zip(actual_array).all? do |expected_item, actual_item|
      (expected_item.to_f - actual_item.to_f).abs <= delta.to_f
    end
  end
end

def assert_ll(lat_lng, lat, lng)
  assert_equal lat_lng, Geokit::LatLng.new(lat, lng)
end
