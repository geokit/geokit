module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is a hostip.info
    # which sources their data through a combination of publicly available information as well
    # as community contributions.
    class IpGeocoder < BaseIpGeocoder
      private

      # Given an IP address, returns a GeoLoc instance which contains latitude,
      # longitude, city, and country code.  Sets the success attribute to false if the ip
      # parameter does not match an ip address.
      def self.do_geocode(ip)
        return GeoLoc.new unless valid_ip?(ip)
        url = submit_url(ip)
        res = call_geocoder_service(url)
        return GeoLoc.new unless net_adapter.success?(res)
        ensure_utf8_encoding(res)
        body = res.body
        body = body.encode('UTF-8') if body.respond_to? :encode
        parse :yaml, body
      end

      def self.submit_url(ip)
        "http://api.hostip.info/get_html.php?ip=#{ip}&position=true"
      end

      # Converts the body to YAML since its in the form of:
      #
      # Country: UNITED STATES (US)
      # City: Sugar Grove, IL
      # Latitude: 41.7696
      # Longitude: -88.4588
      #
      # then instantiates a GeoLoc instance to populate with location data.
      def self.parse_yaml(yaml) # :nodoc:
        loc = new_loc
        loc.city, loc.state_code = yaml['City'].split(', ')
        loc.country, loc.country_code = yaml['Country'].split(' (')
        loc.lat = yaml['Latitude']
        loc.lng = yaml['Longitude']
        loc.country_code.chop!
        loc.success = !(loc.city =~ /\(.+\)/)
        loc
      end

      # Forces UTF-8 encoding on the body
      # Rails expects string input to be UTF-8
      # hostip.info specifies the charset encoding in the headers
      # thus extract encoding from headers and tell Rails about it by forcing it
      def self.ensure_utf8_encoding(res)
        if (enc_string = extract_charset(res))
          if defined?(Encoding) && Encoding.aliases.values.include?(enc_string.upcase)
            res.body.force_encoding(enc_string.upcase) if res.body.respond_to?(:force_encoding)
            res.body.encode('UTF-8')
          else
            require 'iconv'
            res.body.replace Iconv.conv('UTF8', 'iso88591', res.body)
          end
        end
      end

      # Extracts charset out of the response headers
      def self.extract_charset(res)
        if (content_type = res['content-type'])
          capture = content_type.match(/charset=(.+)/)
          capture && capture[1]
        end
      end
    end
  end
end
