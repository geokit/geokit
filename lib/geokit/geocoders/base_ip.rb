module Geokit
  module Geocoders
    class BaseIpGeocoder < Geocoder
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

      def self.valid_ip?(ip)
        ip?(ip) && !private_ip_address?(ip)
      end

      def self.ip?(ip)
        /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
      end

      def self.process(format, ip)
        return GeoLoc.new unless valid_ip?(ip)
        super(format, submit_url(ip))
      end

      # Checks whether the IP address belongs to a private address range.
      #
      # This function is used to reduce the number of useless queries made to
      # the geocoding service. Such queries can occur frequently during
      # integration tests.
      def self.private_ip_address?(ip)
        NON_ROUTABLE_IP_RANGES.any? { |range| range.include?(ip) }
      end
    end
  end
end
