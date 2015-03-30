module Geokit
  module Geocoders
    # Yahoo geocoder implementation.  Requires the Geokit::Geocoders::YAHOO variable to
    # contain a Yahoo API key.  Conforms to the interface set by the Geocoder class.
    class YahooGeocoder < Geocoder
      config :key, :secret
      self.secure = true

      private

      def self.submit_url(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        query_string = "?q=#{Geokit::Inflector.url_escape(address_str)}&flags=J"

        o = OauthUtil.new
        o.consumer_key = key
        o.consumer_secret = secret
        base = "#{protocol}://yboss.yahooapis.com/geo/placefinder"
        parsed_url = URI.parse("#{base}#{query_string}")
        "#{base}?#{o.sign(parsed_url).query_string}"
      end

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        process :json, submit_url(address)
      end

      def self.parse_json(results)
        boss_results = results && results['bossresponse'] && results['bossresponse']['placefinder'] && results['bossresponse']['placefinder']['results']
        return GeoLoc.new unless boss_results && boss_results.first
        loc = nil
        boss_results.each do |result|
          extracted_geoloc = extract_geoloc(result)
          if loc.nil?
            loc = extracted_geoloc
          else
            loc.all.push(extracted_geoloc)
          end
        end
        loc
      end

      def self.extract_geoloc(result_json)
        loc = new_loc
        loc.lat      = result_json['latitude']
        loc.lng      = result_json['longitude']
        set_address_components(result_json, loc)
        set_precision(result_json, loc)
        loc.success  = true
        loc
      end

      def self.set_address_components(result_json, loc)
        loc.country_code   = result_json['countrycode']
        loc.street_address = result_json['line1'].to_s.empty? ? nil : result_json['line1']
        loc.city           = result_json['city']
        loc.state          = loc.is_us? ? result_json['statecode'] : result_json['state']
        loc.zip            = result_json['postal']
      end

      def self.set_precision(result_json, loc)
        loc.precision = case result_json['quality'].to_i
                        when 9, 10         then 'country'
                        when 19..30       then 'state'
                        when 39, 40        then 'city'
                        when 49, 50        then 'neighborhood'
                        when 59, 60, 64     then 'zip'
                        when 74, 75        then 'zip+4'
                        when 70..72       then 'street'
                        when 80..87       then 'address'
                        when 62, 63, 90, 99  then 'building'
                        else 'unknown'
                        end

        loc.accuracy = %w{unknown country state state city zip zip+4 street address building}.index(loc.precision)
      end
    end
  end
end

# Oauth Util
# from gist: https://gist.github.com/erikeldridge/383159
# A utility for signing an url using OAuth in a way that's convenient for debugging
# Note: the standard Ruby OAuth lib is here http://github.com/mojodna/oauth
# License: http://gist.github.com/375593
# Usage: see example.rb below

require 'uri'
require 'cgi'
require 'openssl'
require 'base64'

class OauthUtil
  attr_accessor :consumer_key, :consumer_secret, :token, :token_secret, :req_method,
                :sig_method, :oauth_version, :callback_url, :params, :req_url, :base_str

  def initialize
    @consumer_key = ''
    @consumer_secret = ''
    @token = ''
    @token_secret = ''
    @req_method = 'GET'
    @sig_method = 'HMAC-SHA1'
    @oauth_version = '1.0'
    @callback_url = ''
  end

  # openssl::random_bytes returns non-word chars, which need to be removed. using alt method to get length
  # ref http://snippets.dzone.com/posts/show/491
  def nonce
    Array.new( 5 ) { rand(256) }.pack('C*').unpack('H*').first
  end

  def percent_encode( string )
    # ref http://snippets.dzone.com/posts/show/1260
    URI.escape( string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
  end

  # @ref http://oauth.net/core/1.0/#rfc.section.9.2
  def signature
    key = percent_encode( @consumer_secret ) + '&' + percent_encode( @token_secret )

    # ref: http://blog.nathanielbibler.com/post/63031273/openssl-hmac-vs-ruby-hmac-benchmarks
    digest = OpenSSL::Digest.new( 'sha1' )
    hmac = OpenSSL::HMAC.digest( digest, key, @base_str )

    # ref http://groups.google.com/group/oauth-ruby/browse_thread/thread/9110ed8c8f3cae81
    Base64.encode64( hmac ).chomp.gsub( /\n/, '' )
  end

  # sort (very important as it affects the signature), concat, and percent encode
  # @ref http://oauth.net/core/1.0/#rfc.section.9.1.1
  # @ref http://oauth.net/core/1.0/#9.2.1
  # @ref http://oauth.net/core/1.0/#rfc.section.A.5.1
  def query_string
    pairs = []
    @params.sort.each { | key, val |
      pairs.push( "#{ percent_encode( key ) }=#{ percent_encode( val.to_s ) }" )
    }
    pairs.join '&'
  end

  def timestamp
    Time.now.to_i.to_s
  end

  # organize params & create signature
  def sign( parsed_url )
    @params = {
      'oauth_consumer_key' => @consumer_key,
      'oauth_nonce' => nonce,
      'oauth_signature_method' => @sig_method,
      'oauth_timestamp' => timestamp,
      'oauth_version' => @oauth_version
    }

    # if url has query, merge key/values into params obj overwriting defaults
    if parsed_url.query
      CGI.parse( parsed_url.query ).each do |k, v|
        if v.is_a?(Array) && v.count == 1
          @params[k] = v.first
        else
          @params[k] = v
        end
      end
    end

    # @ref http://oauth.net/core/1.0/#rfc.section.9.1.2
    @req_url = parsed_url.scheme + '://' + parsed_url.host + parsed_url.path

    # create base str. make it an object attr for ez debugging
    # ref http://oauth.net/core/1.0/#anchor14
    @base_str = [
      @req_method,
      percent_encode( req_url ),

      # normalization is just x-www-form-urlencoded
      percent_encode( query_string )

    ].join( '&' )

    # add signature
    @params[ 'oauth_signature' ] = signature

    self
  end
end
