module Geokit
  module Geocoders
    # MapQuest geocoder implementation.  Requires the Geokit::Geocoders::mapquest variable to
    # contain a MapQuest API key.  Conforms to the interface set by the Geocoder class.
    class MapQuestGeocoder < Geocoder

      private

      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng=LatLng.normalize(latlng)
        url="http://www.mapquestapi.com/geocoding/v1/reverse?key=#{Geokit::Geocoders::mapquest}&location=#{latlng.lat},#{latlng.lng}"
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        json = res.body
        logger.debug "MapQuest reverse-geocoding. LL: #{latlng}. Result: #{json}"
        return self.json2GeoLoc(json, latlng)
      end

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url="http://www.mapquestapi.com/geocoding/v1/address?key=#{Geokit::Geocoders::mapquest}&location=#{Geokit::Inflector::url_escape(address_str)}"
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        json = res.body
        logger.debug "Mapquest geocoding. Address: #{address}. Result: #{json}"
        return self.json2GeoLoc(json, address)
      end

      def self.json2GeoLoc(json, address)
        results = MultiJson.load(json)

        if results['info']['statuscode'] == 0
          geoloc = nil
          results['results'].each do |result|
            result['locations'].each do |location|
              extracted_geoloc = extract_geoloc(location)
              if geoloc.nil?
                geoloc = extracted_geoloc
              else
                geoloc.all.push(extracted_geoloc)
              end
            end
          end          
          return geoloc
        else
          logger.info "MapQuest was unable to geocode address: " + address
          return GeoLoc.new
        end
      end

      def self.extract_geoloc(result_json)
        geoloc = GeoLoc.new

        # basic
        geoloc.lat            = result_json['latLng']['lat']
        geoloc.lng            = result_json['latLng']['lng']
        geoloc.country_code   = result_json['adminArea1']
        geoloc.provider       = 'mapquest'

        # extended
        geoloc.street_address = result_json['street'].to_s.empty? ? nil : result_json['street']
        geoloc.city           = result_json['adminArea5']
        geoloc.state          = result_json['adminArea3']
        geoloc.zip            = result_json['postalCode']

        geoloc.precision = result_json['geocodeQuality']
        geoloc.accuracy = %w{unknown country state state city zip zip+4 street address building}.index(geoloc.precision)
        geoloc.success = true

        return geoloc
      end
    end
  end
end
