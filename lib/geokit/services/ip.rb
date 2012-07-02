module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is a hostip.info
    # which sources their data through a combination of publicly available information as well
    # as community contributions.
    class IpGeocoder < Geocoder

      # A number of non-routable IP ranges.
      #
      # --
      # Sources for these:
      #   RFC 3330: Special-Use IPv4 Addresses
      #   The bogon list: http://www.cymru.com/Documents/bogon-list.html

      NON_ROUTABLE_IP_RANGES = [
        IPAddr.new('0.0.0.0/8'),      # "This" Network
        IPAddr.new('10.0.0.0/8'),     # Private-Use Networks
        IPAddr.new('14.0.0.0/8'),     # Public-Data Networks
        IPAddr.new('127.0.0.0/8'),    # Loopback
        IPAddr.new('169.254.0.0/16'), # Link local
        IPAddr.new('172.16.0.0/12'),  # Private-Use Networks
        IPAddr.new('192.0.2.0/24'),   # Test-Net
        IPAddr.new('192.168.0.0/16'), # Private-Use Networks
        IPAddr.new('198.18.0.0/15'),  # Network Interconnect Device Benchmark Testing
        IPAddr.new('224.0.0.0/4'),    # Multicast
        IPAddr.new('240.0.0.0/4')     # Reserved for future use
      ].freeze

      private

      # Given an IP address, returns a GeoLoc instance which contains latitude,
      # longitude, city, and country code.  Sets the success attribute to false if the ip
      # parameter does not match an ip address.
      def self.do_geocode(ip, options = {})
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        return GeoLoc.new if self.private_ip_address?(ip)
        url = "http://api.hostip.info/get_html.php?ip=#{ip}&position=true"
        response = self.call_geocoder_service(url)
        ensure_utf8_encoding(response)
        response.is_a?(Net::HTTPSuccess) ? parse_body(response.body) : GeoLoc.new
      rescue
        logger.error "Caught an error during HostIp geocoding call: " + $!.to_s
        return GeoLoc.new
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
        yaml = YAML.load(body)
        res = GeoLoc.new
        res.provider = 'hostip'
        res.city, res.state = yaml['City'].split(', ')
        country, res.country_code = yaml['Country'].split(' (')
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
          if Encoding.aliases.values.include?(enc_string.upcase)
            response.body.force_encoding(enc_string.upcase) if response.body.respond_to?(:force_encoding)
            response.body.encode("UTF-8")
          end
        end
      end

      # Extracts charset out of the response headers
      def self.extract_charset(response)
        if (content_type = response['content-type'])
          capture = content_type.match(/charset=(?<encoding>.+)/)
          capture && capture['encoding']
        end
      end

      # Checks whether the IP address belongs to a private address range.
      #
      # This function is used to reduce the number of useless queries made to
      # the geocoding service. Such queries can occur frequently during
      # integration tests.
      def self.private_ip_address?(ip)
        return NON_ROUTABLE_IP_RANGES.any? { |range| range.include?(ip) }
      end
    end
  end
end

