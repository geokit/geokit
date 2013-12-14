module Geokit
  module Geocoders
    # Yandex geocoder implementation. Expects the Geokit::Geocoders::YANDEX variable to
    # contain a Yandex API key (optional). Conforms to the interface set by the Geocoder class.
    class YandexGeocoder < Geocoder
      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url = submit_url(address_str)
        res = call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        parse :json, res.body
      end

      def self.submit_url(address_str)
        url = "http://geocode-maps.yandex.ru/1.x/?geocode=#{Geokit::Inflector::url_escape(address_str)}&format=json"
        url += "&key=#{Geokit::Geocoders::yandex}" if Geokit::Geocoders::yandex
        url
      end

      def self.parse_json(result)
        geoloc = GeoLoc.new

        if result["response"]["GeoObjectCollection"]["metaDataProperty"]["GeocoderResponseMetaData"]["found"].to_i > 0
          loc = result["response"]["GeoObjectCollection"]["featureMember"][0]["GeoObject"]

          geoloc.success = true
          geoloc.provider = "yandex"
          geoloc.lng = loc["Point"]["pos"].split(" ").first
          geoloc.lat = loc["Point"]["pos"].split(" ").last

          addr = loc["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]
          country = addr["Country"]
          geoloc.country_code = country["CountryNameCode"]
          geoloc.full_address = country["AddressLine"]
          geoloc.street_address = loc["name"]

          locality = country["Locality"] || country["AdministrativeArea"]["Locality"] || country["AdministrativeArea"]["SubAdministrativeArea"]["Locality"] rescue nil
          geoloc.street_number = locality["Thoroughfare"]["Premise"]["PremiseNumber"] rescue nil
          geoloc.street_name = locality["Thoroughfare"]["ThoroughfareName"] rescue nil
          geoloc.city = locality["LocalityName"] rescue nil
          geoloc.state = country["AdministrativeArea"]["AdministrativeAreaName"] rescue nil
          geoloc.state ||= country["Locality"]["LocalityName"] rescue nil
          geoloc.precision = loc["metaDataProperty"]["GeocoderMetaData"]["precision"].sub(/exact/, "building").sub(/number|near/, "address").sub(/other/, "city")
          geoloc.precision = "country" unless locality
        end

        geoloc
      end
    end
  end
end
