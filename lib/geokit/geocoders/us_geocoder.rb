# Geocoder Us geocoder implementation.  Requires the Geokit::Geocoders::GEOCODER_US variable to
# contain true or false based upon whether authentication is to occur.  Conforms to the
# interface set by the Geocoder class.
module Geokit
 module Geocoders
    class UsGeocoder < Geocoder

      private
      def self.do_geocode(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address

        query = (address_str =~ /^\d{5}(?:-\d{4})?$/ ? "zip" : "address") + "=#{Geokit::Inflector::url_escape(address_str)}"
        url = if Geokit::Geocoders::geocoder_us
          "http://#{Geokit::Geocoders::geocoder_us}@geocoder.us/member/service/csv/geocode"
        else
          "http://geocoder.us/service/csv/geocode"
        end

        url = "#{url}?#{query}"
        res = call_geocoder_service(url)

        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        data = res.body
        logger.debug "Geocoder.us geocoding. Address: #{address}. Result: #{data}"
        parse_csv data
      end

      def self.parse_csv(data)
        array = data.chomp.split(',')

        loc = GeoLoc.new
        if array.length == 5
          loc.lat,loc.lng,loc.city,loc.state,loc.zip=array
          loc.country_code='US'
          loc.success=true
        elsif array.length == 6
          loc.lat,loc.lng,loc.street_address,loc.city,loc.state,loc.zip=array
          loc.country_code='US'
          loc.success=true
        end
        loc
      end
    end
  end
end
