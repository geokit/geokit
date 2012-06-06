module Geokit
  module Geocoders
    class GoogleGeocoder3 < Geocoder

      private
      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng=LatLng.normalize(latlng)
        if !Geokit::Geocoders::google_client_id.nil? and !Geokit::Geocoders::google_cryptographic_key.nil?
          urlToSign = "/maps/api/geocode/json?latlng=#{Geokit::Inflector::url_escape(latlng.ll)}&client=#{Geokit::Geocoders::google_client_id}" + "#{(!Geokit::Geocoders::google_channel.nil? ? ("&channel="+ Geokit::Geocoders::google_channel) : "")}" + "&sensor=false"
          signature = sign_gmap_bus_api_url(urlToSign, Geokit::Geocoders::google_cryptographic_key)
          submit_url =  "http://maps.googleapis.com" + urlToSign + "&signature=#{signature}"
        else
          submit_url = "http://maps.google.com/maps/api/geocode/json?sensor=false&latlng=#{Geokit::Inflector::url_escape(latlng.ll)}"
        end
        res = self.call_geocoder_service(submit_url)
        return GeoLoc.new unless (res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPOK))
        json = res.body
        logger.debug "Google reverse-geocoding. LL: #{latlng}. Result: #{json}"
        return self.json2GeoLoc(json)
      end

      # Template method which does the geocode lookup.
      #
      # Supports viewport/country code biasing
      #
      # ==== OPTIONS
      # * :bias - This option makes the Google Geocoder return results biased to a particular
      #           country or viewport. Country code biasing is achieved by passing the ccTLD
      #           ('uk' for .co.uk, for example) as a :bias value. For a list of ccTLD's,
      #           look here: http://en.wikipedia.org/wiki/CcTLD. By default, the geocoder
      #           will be biased to results within the US (ccTLD .com).
      #
      #           If you'd like the Google Geocoder to prefer results within a given viewport,
      #           you can pass a Geokit::Bounds object as the :bias value.
      #
      # ==== EXAMPLES
      # # By default, the geocoder will return Syracuse, NY
      # Geokit::Geocoders::GoogleGeocoder.geocode('Syracuse').country_code # => 'US'
      # # With country code biasing, it returns Syracuse in Sicily, Italy
      # Geokit::Geocoders::GoogleGeocoder.geocode('Syracuse', :bias => :it).country_code # => 'IT'
      #
      # # By default, the geocoder will return Winnetka, IL
      # Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka').state # => 'IL'
      # # When biased to an bounding box around California, it will now return the Winnetka neighbourhood, CA
      # bounds = Geokit::Bounds.normalize([34.074081, -118.694401], [34.321129, -118.399487])
      # Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka', :bias => bounds).state # => 'CA'
      def self.do_geocode(address, options = {})
        bias_str = options[:bias] ? construct_bias_string_from_options(options[:bias]) : ''
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        if !Geokit::Geocoders::google_client_id.nil? and !Geokit::Geocoders::google_cryptographic_key.nil?
          urlToSign = "/maps/api/geocode/json?address=#{Geokit::Inflector::url_escape(address_str)}#{bias_str}&client=#{Geokit::Geocoders::google_client_id}" + "#{(!Geokit::Geocoders::google_channel.nil? ? ("&channel="+ Geokit::Geocoders::google_channel) : "")}" + "&sensor=false"
          signature = sign_gmap_bus_api_url(urlToSign, Geokit::Geocoders::google_cryptographic_key)
          submit_url =  "http://maps.googleapis.com" + urlToSign + "&signature=#{signature}"
        else
          submit_url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(address_str)}#{bias_str}"
        end

        res = self.call_geocoder_service(submit_url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)

        json = res.body
        logger.debug "Google geocoding. Address: #{address}. Result: #{json}"

        return self.json2GeoLoc(json, address)
      end

            # This code comes from Googles Examples
      # http://gmaps-samples.googlecode.com/svn/trunk/urlsigning/urlsigner.rb
      def self.sign_gmap_bus_api_url(urlToSign, google_cryptographic_key)
        # Decode the private key
        rawKey = Base64.decode64(google_cryptographic_key.tr('-_','+/'))
        # create a signature using the private key and the URL
        sha1 = HMAC::SHA1.new(rawKey)
        sha1 << urlToSign
        rawSignature = sha1.digest()
        # encode the signature into base64 for url use form.
        return Base64.encode64(rawSignature).tr('+/','-_')
      end


      def self.construct_bias_string_from_options(bias)
        if bias.is_a?(String) or bias.is_a?(Symbol)
          # country code biasing
          "&region=#{bias.to_s.downcase}"
        elsif bias.is_a?(Bounds)
          # viewport biasing
          Geokit::Inflector::url_escape("&bounds=#{bias.sw.to_s}|#{bias.ne.to_s}")
        end
      end

      def self.json2GeoLoc(json, address="")
        ret=nil
        results = MultiJson.load(json)

        if results['status'] == 'OVER_QUERY_LIMIT'
          raise Geokit::TooManyQueriesError
        end
        if results['status'] == 'ZERO_RESULTS'
          return GeoLoc.new
        end
        # this should probably be smarter.
        if results['status'] != 'OK'
          raise Geokit::Geocoders::GeocodeError
        end
        # location_type stores additional data about the specified location.
        # The following values are currently supported:
        # "ROOFTOP" indicates that the returned result is a precise geocode
        # for which we have location information accurate down to street
        # address precision.
        # "RANGE_INTERPOLATED" indicates that the returned result reflects an
        # approximation (usually on a road) interpolated between two precise
        # points (such as intersections). Interpolated results are generally
        # returned when rooftop geocodes are unavailable for a street address.
        # "GEOMETRIC_CENTER" indicates that the returned result is the
        # geometric center of a result such as a polyline (for example, a
        # street) or polygon (region).
        # "APPROXIMATE" indicates that the returned result is approximate

        # these do not map well. Perhaps we should guess better based on size
        # of bounding box where it exists? Does it really matter?
        accuracy = {
          "ROOFTOP" => 9,
          "RANGE_INTERPOLATED" => 8,
          "GEOMETRIC_CENTER" => 5,
          "APPROXIMATE" => 4
        }

        @unsorted = []

        results['results'].each do |addr|
          res = GeoLoc.new
          res.provider = 'google3'
          res.success = true
          res.full_address = addr['formatted_address']

          addr['address_components'].each do |comp|
            case
            when comp['types'].include?("subpremise")
              res.sub_premise = comp['short_name']
            when comp['types'].include?("street_number")
              res.street_number = comp['short_name']
            when comp['types'].include?("route")
              res.street_name = comp['long_name']
            when comp['types'].include?("locality")
              res.city = comp['long_name']
            when comp['types'].include?("administrative_area_level_1")
              res.state = comp['short_name']
              res.province = comp['short_name']
            when comp['types'].include?("postal_code")
              res.zip = comp['long_name']
            when comp['types'].include?("country")
              res.country_code = comp['short_name']
              res.country = comp['long_name']
            when comp['types'].include?("administrative_area_level_2")
              res.district = comp['long_name']
            when comp['types'].include?('neighborhood')
              res.neighborhood = comp['short_name']
            end
          end
          if res.street_name
            res.street_address=[res.street_number,res.street_name].join(' ').strip
          end
          res.accuracy = accuracy[addr['geometry']['location_type']]
          res.precision=%w{unknown country state state city zip zip+4 street address building}[res.accuracy]
          # try a few overrides where we can
          if res.sub_premise
            res.accuracy = 9
            res.precision = 'building'
          end
          if res.street_name && res.precision=='city'
            res.precision = 'street'
            res.accuracy = 7
          end

          res.lat=addr['geometry']['location']['lat'].to_f
          res.lng=addr['geometry']['location']['lng'].to_f

          ne=Geokit::LatLng.new(
            addr['geometry']['viewport']['northeast']['lat'].to_f,
            addr['geometry']['viewport']['northeast']['lng'].to_f
          )
          sw=Geokit::LatLng.new(
            addr['geometry']['viewport']['southwest']['lat'].to_f,
            addr['geometry']['viewport']['southwest']['lng'].to_f
          )
          res.suggested_bounds = Geokit::Bounds.new(sw,ne)

          @unsorted << res
        end

        all = @unsorted.sort_by { |a| a.accuracy }.reverse
        encoded = all.first
        encoded.all = all
        return encoded
      end
    end
    Google3Geocoder = GoogleGeocoder3
  end
end
