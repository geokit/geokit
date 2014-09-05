module Geokit
  module Geocoders
    class GeocodioGeocoder < Geocoder
      config :key

      private

      def self.do_geocode(address)
        process :json, submit_url(address)
      end

      def self.submit_url(address)
        params = [
          "q=#{Geokit::Inflector.url_escape(address)}",
          "api_key=#{key}"
        ].join('&')

        ['http://api.geocod.io/v1/geocode', params].join('?')
      end

      def self.parse_json(json)
        loc = nil

        json['results'].each do |address|
          if loc.nil?
            loc = create_new_loc(address)
          else
            loc.all.push(create_new_loc(address))
          end
        end
        loc.success = true
        loc
      end

      def self.create_new_loc(json)
        loc = new_loc
        set_address_components(json, loc)
        set_coordinates(json, loc)
        loc
      end

      def self.set_address_components(json, loc)
        loc.street_address  = json['address_components']['street']
        loc.street_number   = json['address_components']['number']
        loc.sub_premise     = json['address_components']['suffix']
        loc.street_name     = json['address_components']['street']
        loc.city            = json['address_components']['city']
        loc.state           = json['address_components']['state']
        loc.zip             = json['address_components']['zip']
        loc.full_address    = json['formatted_address']
      end

      def self.set_coordinates(json, loc)
        loc.lat = json['location']['lat']
        loc.lng = json['location']['lng']
      end
    end
  end
end
