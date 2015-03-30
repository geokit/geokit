module Geokit
  module Geocoders
    # Yandex geocoder implementation. Expects the Geokit::Geocoders::YANDEX variable to
    # contain a Yandex API key (optional). Conforms to the interface set by the Geocoder class.
    class YandexGeocoder < Geocoder
      config :key

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address)
        process :json, submit_url(address)
      end

      def self.submit_url(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url = "http://geocode-maps.yandex.ru/1.x/?geocode=#{Geokit::Inflector.url_escape(address_str)}&format=json"
        url += "&key=#{key}" if key
        url
      end

      def self.parse_json(result)
        loc = new_loc

        coll = result['response']['GeoObjectCollection']
        return loc unless coll['metaDataProperty']['GeocoderResponseMetaData']['found'].to_i > 0

        l = coll['featureMember'][0]['GeoObject']

        loc.success = true
        ll = l['Point']['pos'].split(' ')
        loc.lng = ll.first
        loc.lat = ll.last

        country = l['metaDataProperty']['GeocoderMetaData']['AddressDetails']['Country']
        locality = country['Locality'] || country['AdministrativeArea']['Locality'] || country['AdministrativeArea']['SubAdministrativeArea']['Locality'] rescue nil
        set_address_components(loc, l, country, locality)
        set_precision(loc, l, locality)

        loc
      end

      def self.set_address_components(loc, l, country, locality)
        loc.country_code = country['CountryNameCode']
        loc.full_address = country['AddressLine']
        loc.street_address = l['name']
        loc.street_number = locality['Thoroughfare']['Premise']['PremiseNumber'] rescue nil
        loc.street_name = locality['Thoroughfare']['ThoroughfareName'] rescue nil
        loc.city = locality['LocalityName'] rescue nil
        loc.state_name = country['AdministrativeArea']['AdministrativeAreaName'] rescue nil
        loc.state ||= country['Locality']['LocalityName'] rescue nil
      end

      def self.set_precision(loc, l, locality)
        loc.precision = l['metaDataProperty']['GeocoderMetaData']['precision'].sub(/exact/, 'building').sub(/number|near/, 'address').sub(/other/, 'city')
        loc.precision = 'country' unless locality
      end
    end
  end
end
