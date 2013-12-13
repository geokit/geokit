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
      def self.do_geocode(ip, options = {})
        return GeoLoc.new unless valid_ip?(ip)
        url = "http://api.hostip.info/get_html.php?ip=#{ip}&position=true"
        response = call_geocoder_service(url)
        ensure_utf8_encoding(response)
        response.is_a?(Net::HTTPSuccess) ? parse_body(response.body) : GeoLoc.new
      end

      # Converts the body to YAML since its in the form of:
      #
      # Country: UNITED STATES (US)
      # City: Sugar Grove, IL
      # Latitude: 41.7696
      # Longitude: -88.4588
      #
      # then instantiates a GeoLoc instance to populate with location data.
      def self.parse_body(body) # :nodoc:
        body = body.encode('UTF-8') if body.respond_to? :encode
        yaml = YAML.load(body)
        res = GeoLoc.new
        res.provider = 'hostip'
        res.city, res.state = yaml['City'].split(', ')
        res.country, res.country_code = yaml['Country'].split(' (')
        res.lat = yaml['Latitude']
        res.lng = yaml['Longitude']
        res.country_code.chop!
        res.success = !(res.city =~ /\(.+\)/)
        res
      end

      # Forces UTF-8 encoding on the body
      # Rails expects string input to be UTF-8
      # hostip.info specifies the charset encoding in the headers
      # thus extract encoding from headers and tell Rails about it by forcing it
      def self.ensure_utf8_encoding(response)
        if (enc_string = extract_charset(response))
          if defined?(Encoding) && Encoding.aliases.values.include?(enc_string.upcase)
            response.body.force_encoding(enc_string.upcase) if response.body.respond_to?(:force_encoding)
            response.body.encode("UTF-8")
          else
            require 'iconv'
            response.body.replace Iconv.conv("UTF8", "iso88591", response.body)
          end
        end
      end

      # Extracts charset out of the response headers
      def self.extract_charset(response)
        if (content_type = response['content-type'])
          capture = content_type.match(/charset=(.+)/)
          capture && capture[1]
        end
      end
    end
  end
end

