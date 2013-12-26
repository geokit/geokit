module Geokit
  module Geocoders
    # Yandex geocoder implementation. Expects the Geokit::Geocoders::YANDEX variable to
    # contain a Yandex API key (optional). Conforms to the interface set by the Geocoder class.
    class YandexGeocoder < Geocoder
      config :key

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
        url += "&key=#{key}" if key
        url
      end

      def self.parse_json(result)
        loc = GeoLoc.new

        coll = result["response"]["GeoObjectCollection"]
        return loc unless coll["metaDataProperty"]["GeocoderResponseMetaData"]["found"].to_i > 0

        l = coll["featureMember"][0]["GeoObject"]

        loc.success = true
        loc.provider = "yandex"
        loc.lng = l["Point"]["pos"].split(" ").first
        loc.lat = l["Point"]["pos"].split(" ").last

        country = l["metaDataProperty"]["GeocoderMetaData"]["AddressDetails"]["Country"]
        locality = country["Locality"] || country["AdministrativeArea"]["Locality"] || country["AdministrativeArea"]["SubAdministrativeArea"]["Locality"] rescue nil
        set_address_components(loc, l, country, locality)
        set_precision(loc, l, locality)

        loc
      end

      def self.set_address_components(loc, l, country, locality)
        loc.country_code = country["CountryNameCode"]
        loc.full_address = country["AddressLine"]
        loc.street_address = l["name"]
        loc.street_number = locality["Thoroughfare"]["Premise"]["PremiseNumber"] rescue nil
        loc.street_name = locality["Thoroughfare"]["ThoroughfareName"] rescue nil
        loc.city = locality["LocalityName"] rescue nil
        loc.state = country["AdministrativeArea"]["AdministrativeAreaName"] rescue nil
        loc.state ||= country["Locality"]["LocalityName"] rescue nil
      end

      def self.set_precision(loc, l, locality)
        loc.precision = l["metaDataProperty"]["GeocoderMetaData"]["precision"].sub(/exact/, "building").sub(/number|near/, "address").sub(/other/, "city")
        loc.precision = "country" unless locality
      end
    end
  end
end
