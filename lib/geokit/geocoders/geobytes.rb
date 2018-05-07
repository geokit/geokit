module Geokit
  module Geocoders
    # Provides geocoding based upon an IP address.  The underlying web service is GeoSelect
    class GeobytesGeocoder < BaseIpGeocoder
      def self.do_geocode(ip, _=nil)
        process :json, ip
      end

      def self.submit_url(ip)
        "http://getcitydetails.geobytes.com/GetCityDetails?fqcn=#{ip}"
      end

      def self.parse_json(json)
        loc = new_loc
        loc.city          = json['geobytescity']
        loc.country_code  = json['geobytesinternet']
        loc.full_address  = json['geobytesfqcn']
        loc.lat           = json['geobyteslatitude']
        loc.lng           = json['geobyteslongitude']
        loc.state         = json['geobytescode']
        loc.precision     = json['geobytescertainty']
        loc.state_name    = json['geobytesregion']
        loc.success       = !json['geobytescity'].empty?
        loc
      end
    end
  end
end
