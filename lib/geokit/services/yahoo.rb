module Geokit
  module Geocoders
    # Yahoo geocoder implementation.  Requires the Geokit::Geocoders::YAHOO variable to
    # contain a Yahoo API key.  Conforms to the interface set by the Geocoder class.
    class YahooGeocoder < Geocoder

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url="http://where.yahooapis.com/geocode?flags=J&appid=#{Geokit::Geocoders::yahoo}&q=#{Geokit::Inflector::url_escape(address_str)}"
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        json = res.body
        logger.debug "Yahoo geocoding. Address: #{address}. Result: #{json}"
        return self.json2GeoLoc(json, address)
      end

      def self.json2GeoLoc(json, address)
        results = MultiJson.load(json)

        if results['ResultSet']['Error'].to_i == 0 && results['ResultSet']['Results'] != nil && results['ResultSet']['Results'].first != nil
          geoloc = nil
          results['ResultSet']['Results'].each do |result|
            extracted_geoloc = extract_geoloc(result)
            if geoloc.nil?
              geoloc = extracted_geoloc
            else
              geoloc.all.push(extracted_geoloc)
            end
          end
          return geoloc
        else
          logger.info "Yahoo was unable to geocode address: " + address
          return GeoLoc.new
        end
      end

      def self.extract_geoloc(result_json)
        geoloc = GeoLoc.new

        # basic
        geoloc.lat            = result_json['latitude']
        geoloc.lng            = result_json['longitude']
        geoloc.country_code   = result_json['countrycode']
        geoloc.provider       = 'yahoo'

        # extended
        geoloc.street_address = result_json['line1'].to_s.empty? ? nil : result_json['line1']
        geoloc.city           = result_json['city']
        geoloc.state          = geoloc.is_us? ? result_json['statecode'] : result_json['state']
        geoloc.zip            = result_json['postal']

        geoloc.precision = case result_json['quality']
                           when 9,10         then 'country'
                           when 19..30       then 'state'
                           when 39,40        then 'city'
                           when 49,50        then 'neighborhood'
                           when 59,60,64     then 'zip'
                           when 74,75        then 'zip+4'
                           when 70..72       then 'street'
                           when 80..87       then 'address'
                           when 62,63,90,99  then 'building'
                           else 'unknown'
                           end

        geoloc.accuracy = %w{unknown country state state city zip zip+4 street address building}.index(geoloc.precision)
        geoloc.success = true

        return geoloc
      end
    end
  end
end
