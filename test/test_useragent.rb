require 'test/unit'
require 'webmock/test_unit'

require File.join(File.dirname(__FILE__), '../lib/geokit.rb')

class UserAgentTest < Test::Unit::TestCase

    NETHTTPDEFAULT          = 'Ruby'
    NETHTTPDEFAULTHEADERS   = {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'}
    TYPHOEUSDEFAULT         = 'Typhoeus - https://github.com/typhoeus/typhoeus'
    TYPHOEUSDEFAULTHEADERS  = {}
    TESTAGENT               = 'MyAgent'
    URL                     = 'http://www.example.com'

    def test_nethttp_useragent_set_to_testagent
        stub_request(:get, URL).with(:headers => NETHTTPDEFAULTHEADERS.merge('User-Agent' => TESTAGENT))

        Geokit::Geocoders::useragent = TESTAGENT
        Geokit::NetAdapter::NetHttp.do_get(URL)
        assert_requested :get, URL
    end

    def test_nethttp_useragent_set_to_default
        stub_request(:get, URL).with(:headers => NETHTTPDEFAULTHEADERS.merge('User-Agent' => NETHTTPDEFAULT))

        Geokit::Geocoders::useragent = nil
        Geokit::NetAdapter::NetHttp.do_get(URL)
        assert_requested :get, URL
    end

    def test_typhoeus_set_to_testagent
        stub_request(:get, URL).with(:headers => TYPHOEUSDEFAULTHEADERS.merge('User-Agent' => TESTAGENT))

        Geokit::Geocoders::useragent = TESTAGENT
        Geokit::NetAdapter::Typhoeus.do_get(URL)
        assert_requested :get, URL
    end

    def test_typhoeus_set_to_default
        stub_request(:get, URL).with(:headers => TYPHOEUSDEFAULTHEADERS.merge('User-Agent' => TYPHOEUSDEFAULT))

        Geokit::Geocoders::useragent = nil
        Geokit::NetAdapter::Typhoeus.do_get(URL)
        assert_requested :get, URL
    end
end
