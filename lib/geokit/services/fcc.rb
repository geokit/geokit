module Geokit
  module Geocoders
    class FCCGeocoder < Geocoder

      private
      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng=LatLng.normalize(latlng)
        res = self.call_geocoder_service("http://data.fcc.gov/api/block/find?format=json&latitude=#{Geokit::Inflector::url_escape(latlng.lat.to_s)}&longitude=#{Geokit::Inflector::url_escape(latlng.lng.to_s)}")
        return GeoLoc.new unless (res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPOK))
        json = res.body
        logger.debug "FCC reverse-geocoding. LL: #{latlng}. Result: #{json}"
        return self.json2GeoLoc(json)
      end

      # Template method which does the geocode lookup.
      #
      # ==== EXAMPLES
      # ll=GeoKit::LatLng.new(40, -85)
      # Geokit::Geocoders::FCCGeocoder.geocode(ll) #

      # JSON result looks like this
      # => {"County"=>{"name"=>"Wayne", "FIPS"=>"18177"},
      # "Block"=>{"FIPS"=>"181770103002004"},
      # "executionTime"=>"0.099",
      # "State"=>{"name"=>"Indiana", "code"=>"IN", "FIPS"=>"18"},
      # "status"=>"OK"}

      def self.json2GeoLoc(json, address="")
        ret = nil
        results = MultiJson.load(json)

        if results.has_key?('Err') and results['Err']["msg"] == 'There are no results for this location'
          return GeoLoc.new
        end
        # this should probably be smarter.
        if !results['status'] == 'OK'
          raise Geokit::Geocoders::GeocodeError
        end

        res = GeoLoc.new
        res.provider      = 'fcc'
        res.success       = true
        res.precision     = 'block'
        res.country_code  = 'US'
        res.district      = results['County']['name']
        res.district_fips = results['County']['FIPS']
        res.state         = results['State']['code']
        res.state_fips    = results['State']['FIPS']
        res.block_fips    = results['Block']['FIPS']

        res
      end
    end

  end
end
