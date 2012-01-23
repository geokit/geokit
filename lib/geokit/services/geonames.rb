module Geokit
  module Geocoders
    # Another geocoding web service
    # http://www.geonames.org
    class GeonamesGeocoder < Geocoder

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        # geonames need a space seperated search string
        address_str.gsub!(/,/, " ")
        params = "/postalCodeSearch?placename=#{Geokit::Inflector::url_escape(address_str)}&maxRows=10"

        if(GeoKit::Geocoders::geonames)
          url = "http://ws.geonames.net#{params}&username=#{GeoKit::Geocoders::geonames}"
        else
          url = "http://ws.geonames.org#{params}"
        end

        res = self.call_geocoder_service(url)

        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)

        xml=res.body
        logger.debug "Geonames geocoding. Address: #{address}. Result: #{xml}"
        doc=REXML::Document.new(xml)

        if(doc.elements['//geonames/totalResultsCount'].text.to_i > 0)
          res=GeoLoc.new

          # only take the first result
          res.lat=doc.elements['//code/lat'].text if doc.elements['//code/lat']
          res.lng=doc.elements['//code/lng'].text if doc.elements['//code/lng']
          res.country_code=doc.elements['//code/countryCode'].text if doc.elements['//code/countryCode']
          res.provider='genomes'
          res.city=doc.elements['//code/name'].text if doc.elements['//code/name']
          res.state=doc.elements['//code/adminName1'].text if doc.elements['//code/adminName1']
          res.zip=doc.elements['//code/postalcode'].text if doc.elements['//code/postalcode']
          res.success=true
          return res
        else
          logger.info "Geonames was unable to geocode address: "+address
          return GeoLoc.new
        end

      rescue
        logger.error "Caught an error during Geonames geocoding call: "+$!
      end
    end
  end
end
