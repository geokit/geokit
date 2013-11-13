module Geokit
  module Geocoders
    # Yandex geocoder implementation. Expects the Geokit::Geocoders::YANDEX variable to
    # contain a Yandex API key (optional). Conforms to the interface set by the Geocoder class.
    class YandexGeocoder < Geocoder
      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url = "http://geocode-maps.yandex.ru/1.x/?geocode=#{Geokit::Inflector::url_escape(address_str)}&format=json"
        url += "&key=#{Geokit::Geocoders::yandex}" if Geokit::Geocoders::yandex != 'REPLACE_WITH_YOUR_YANDEX_KEY'
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        json = res.body
        # logger.debug "Yandex geocoding. Address: #{address}. Result: #{json}"
        return self.json2GeoLoc(json, address)
      end

      def self.json2GeoLoc(json, address)
        geoloc = GeoLoc.new

        result = MultiJson.load(json)
        if result["response"]["GeoObjectCollection"]["metaDataProperty"]["GeocoderResponseMetaData"]["found"].to_i > 0
          loc = result["response"]["GeoObjectCollection"]["featureMember"][0]["GeoObject"]

          geoloc.success = true
          geoloc.provider = "yandex"
          geoloc.lng = loc["Point"]["pos"].split(" ").first
          geoloc.lat = loc["Point"]["pos"].split(" ").last
          geoloc.country_code = loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]["CountryNameCode"]
          geoloc.full_address = loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]["AddressLine"]
          geoloc.street_address = loc["name"]

          locality = loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]["Locality"] || loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]["AdministrativeArea"]["Locality"] || loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]["AdministrativeArea"]["SubAdministrativeArea"]["Locality"] rescue nil
          geoloc.street_number = locality["Thoroughfare"]["Premise"]["PremiseNumber"] rescue nil
          geoloc.street_name = locality["Thoroughfare"]["ThoroughfareName"] rescue nil
          geoloc.city = locality["LocalityName"] rescue nil
          geoloc.state = loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]["AdministrativeArea"]["AdministrativeAreaName"] rescue nil
          geoloc.state ||= loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]["Locality"]["LocalityName"] rescue nil
          geoloc.precision = loc["metaDataProperty"]["GeocoderMetaData"]["precision"].sub(/exact/, "building").sub(/number|near/, "address").sub(/other/, "city")
          geoloc.precision = "country" unless locality
        else
          logger.info "Yandex was unable to geocode address: " + address
        end

        return geoloc
      end
    end
  end
end
