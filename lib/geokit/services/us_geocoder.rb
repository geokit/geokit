# Geocoder Us geocoder implementation.  Requires the Geokit::Geocoders::GEOCODER_US variable to
# contain true or false based upon whether authentication is to occur.  Conforms to the
# interface set by the Geocoder class.
module Geokit
 module Geocoders
    class UsGeocoder < Geocoder

      private
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address

        query = (address_str =~ /^\d{5}(?:-\d{4})?$/ ? "zip" : "address") + "=#{Geokit::Inflector::url_escape(address_str)}"
        url = if GeoKit::Geocoders::geocoder_us
          "http://#{GeoKit::Geocoders::geocoder_us}@geocoder.us/member/service/csv/geocode"
        else
          "http://geocoder.us/service/csv/geocode"
        end

        url = "#{url}?#{query}"
        res = self.call_geocoder_service(url)

        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        data = res.body
        logger.debug "Geocoder.us geocoding. Address: #{address}. Result: #{data}"
        array = data.chomp.split(',')

        if array.length == 5
          res=GeoLoc.new
          res.lat,res.lng,res.city,res.state,res.zip=array
          res.country_code='US'
          res.success=true
          return res
        elsif array.length == 6
          res=GeoLoc.new
          res.lat,res.lng,res.street_address,res.city,res.state,res.zip=array
          res.country_code='US'
          res.success=true
          return res
        else
          logger.info "geocoder.us was unable to geocode address: "+address
          return GeoLoc.new
        end
        rescue
          logger.error "Caught an error during geocoder.us geocoding call: "+$!
          return GeoLoc.new

      end
    end
 end
end
