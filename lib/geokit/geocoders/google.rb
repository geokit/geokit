module Geokit
  module Geocoders
    class GoogleGeocoder < Geocoder
      config :client_id, :cryptographic_key, :channel, :api_key, :host
      self.secure = true

      private

      # ==== OPTIONS
      # * :language - See: https://developers.google.com/maps/documentation/geocoding
      # * :result_type - This option allows restricting results by specific result types.
      #                  See https://developers.google.com/maps/documentation/geocoding/intro#reverse-restricted
      #                  Note: This parameter is available only for requests that include an API key or a client ID.
      # * :location_type - This option allows restricting results by specific location type.
      #                    See https://developers.google.com/maps/documentation/geocoding/intro#reverse-restricted
      #                    Note: This parameter is available only for requests that include an API key or a client ID.
      def self.do_reverse_geocode(latlng, options = {})
        latlng = LatLng.normalize(latlng)
        latlng_str = "latlng=#{Geokit::Inflector.url_escape(latlng.ll)}"
        result_type_str = options[:result_type] ? "&result_type=#{options[:result_type]}" : ''
        location_type_str = options[:location_type] ? "&location_type=#{options[:location_type]}" : ''
        url = submit_url("#{latlng_str}#{result_type_str}#{location_type_str}", options)
        process :json, url
      end

      # ==== OPTIONS
      # * :language - See: https://developers.google.com/maps/documentation/geocoding
      # * :bias - This option makes the Google Geocoder return results biased to a particular
      #           country or viewport. Country code biasing is achieved by passing the ccTLD
      #           ('uk' for .co.uk, for example) as a :bias value. For a list of ccTLD's,
      #           look here: http://en.wikipedia.org/wiki/CcTLD. By default, the geocoder
      #           will be biased to results within the US (ccTLD .com).
      #
      #           If you'd like the Google Geocoder to prefer results within a given viewport,
      #           you can pass a Geokit::Bounds object as the :bias value.
      # * :components - This option allows restricting results by specific areas. See
      #           https://developers.google.com/maps/documentation/geocoding/intro#ComponentFiltering
      #           for details.
      #
      # ==== EXAMPLES
      # # By default, the geocoder will return Toledo, OH
      # Geokit::Geocoders::GoogleGeocoder.geocode('Toledo').country_code # => 'US'
      # # With country code biasing, it returns Toledo (spannish city), Spain
      # Geokit::Geocoders::GoogleGeocoder.geocode('Toledo', :bias => :es).country_code # => 'Es'
      #
      # # By default, the geocoder will return Winnetka, IL
      # Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka').state # => 'IL'
      # # When biased to an bounding box around California, it will now return the Winnetka neighbourhood, CA
      # bounds = Geokit::Bounds.normalize([34.074081, -118.694401], [34.321129, -118.399487])
      # Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka', :bias => bounds).state # => 'CA'
      #
      # # By default, the geocoder will return several matches for Austin with
      # the first one being in Texas
      # Geokit::Geocoders::GoogleGeocoder.geocode('Austin').state # => 'TX'
      # # Using Component Filtering the results can be restricted to a specific
      # area, e.g. IL
      # Geokit::Geocoders::GoogleGeocoder.geocode('Austin',
      #   :components => {administrative_area: 'IL', country: 'US'}).state # => 'IL'
      def self.do_geocode(address, options = {})
        type = options[:type] || 'address'
        bias_str = options[:bias] ? construct_bias_string_from_options(options[:bias]) : ''
        components_str = options[:components] ? construct_components_string_from_options(options[:components]) : ''
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url = submit_url("#{type}=#{Geokit::Inflector.url_escape(address_str)}#{bias_str}#{components_str}", options)
        process :json, url
      end

      # This code comes from Googles Examples
      # http://gmaps-samples.googlecode.com/svn/trunk/urlsigning/urlsigner.rb
      def self.sign_gmap_bus_api_url(urlToSign, google_cryptographic_key)
        require 'base64'
        require 'openssl'
        # Decode the private key
        rawKey = Base64.decode64(google_cryptographic_key.tr('-_', '+/'))
        # create a signature using the private key and the URL
        rawSignature = OpenSSL::HMAC.digest('sha1', rawKey, urlToSign)
        # encode the signature into base64 for url use form.
        Base64.encode64(rawSignature).tr('+/', '-_').gsub(/\n/, '')
      end

      def self.submit_url(query_string, options = {})
        language_str = options[:language] ? "&language=#{options[:language]}" : ''
        query_string = "/maps/api/geocode/json?sensor=false&#{query_string}#{language_str}"
        if client_id && cryptographic_key
          channel_string = channel ? "&channel=#{channel}" : ''
          urlToSign = query_string + "&client=#{client_id}" + channel_string
          signature = sign_gmap_bus_api_url(urlToSign, cryptographic_key)
          "#{protocol}://maps.googleapis.com" + urlToSign + "&signature=#{signature}"
        elsif api_key
          url_with_key = query_string + "&key=#{api_key}"
          "#{protocol}://maps.googleapis.com" + url_with_key
        else
          request_host = host || 'maps.google.com'
          "#{protocol}://#{request_host}#{query_string}"
        end
      end

      def self.construct_bias_string_from_options(bias)
        case bias
        when String, Symbol
          # country code biasing
          "&region=#{bias.to_s.downcase}"
        when Bounds
          # viewport biasing
          url_escaped_string = Geokit::Inflector.url_escape("#{bias.sw}|#{bias.ne}")
          "&bounds=#{url_escaped_string}"
        end
      end

      def self.construct_components_string_from_options(components={})
        unless components.empty?
          "&components=#{components.to_a.map { |pair| pair.join(':').downcase }.join(CGI.escape('|'))}"
        end
      end

      def self.parse_json(results)
        case results['status']
        when 'OVER_QUERY_LIMIT'
          raise Geokit::Geocoders::TooManyQueriesError, results['error_message']
        when 'REQUEST_DENIED'
          raise Geokit::Geocoders::AccessDeniedError, results['error_message']
        when 'ZERO_RESULTS'
          return GeoLoc.new
        when 'OK'
          # all good
        else
          raise Geokit::Geocoders::GeocodeError, results['error_message']
        end

        unsorted = results['results'].map do |addr|
          single_json_to_geoloc(addr)
        end

        all = unsorted
        encoded = all.first
        encoded.all = all
        encoded
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
      ACCURACY = {
        'ROOFTOP' => 9,
        'RANGE_INTERPOLATED' => 8,
        'GEOMETRIC_CENTER' => 5,
        'APPROXIMATE' => 4,
      }

      PRECISIONS = %w(unknown country state state city zip zip+4 street address building)

      def self.single_json_to_geoloc(addr)
        loc = new_loc
        loc.success = true
        loc.full_address = addr['formatted_address']

        set_address_components(loc, addr)
        set_precision(loc, addr)
        if loc.street_name
          loc.street_address = [loc.street_number, loc.street_name].join(' ').strip
        end

        ll = addr['geometry']['location']
        loc.lat = ll['lat'].to_f
        loc.lng = ll['lng'].to_f

        set_bounds(loc, addr)

        loc.place_id = addr['place_id']
        loc.formatted_address = addr['formatted_address']

        loc
      end

      def self.set_bounds(loc, addr)
        viewport = addr['geometry']['viewport']
        ne = Geokit::LatLng.from_json(viewport['northeast'])
        sw = Geokit::LatLng.from_json(viewport['southwest'])
        loc.suggested_bounds = Geokit::Bounds.new(sw, ne)
      end

      def self.set_address_components(loc, addr)
        addr['address_components'].each do |comp|
          types = comp['types']
          case
          when types.include?('subpremise')
            loc.sub_premise = comp['short_name']
          when types.include?('street_number')
            loc.street_number = comp['short_name']
          when types.include?('route')
            loc.street_name = comp['long_name']
          when types.include?('locality')
            loc.city = comp['long_name']
          when types.include?('administrative_area_level_1') # state
            loc.state_code = comp['short_name']
            loc.state_name = comp['long_name']
          when types.include?('postal_town')
            loc.city = comp['long_name']
          when types.include?('postal_code')
            loc.zip = comp['long_name']
          when types.include?('country')
            loc.country_code = comp['short_name']
            loc.country = comp['long_name']
          when types.include?('administrative_area_level_2')
            loc.district = comp['long_name']
          when types.include?('neighborhood')
            loc.neighborhood = comp['short_name']
          # Use either sublocality or admin area level 3 if google does not return a city
          when types.include?('sublocality')
            loc.city = comp['long_name'] if loc.city.nil?
          when types.include?('administrative_area_level_3')
            loc.city = comp['long_name'] if loc.city.nil?
          end
        end
      end

      def self.set_precision(loc, addr)
        loc.accuracy = ACCURACY[addr['geometry']['location_type']]
        loc.precision = PRECISIONS[loc.accuracy]
        # try a few overrides where we can
        if loc.sub_premise
          loc.precision = PRECISIONS[9]
          loc.accuracy  = 9
        end
        if loc.street_name && loc.precision == 'city'
          loc.precision = PRECISIONS[7]
          loc.accuracy  = 7
        end
        if addr['types'].include?('postal_code')
          loc.precision = PRECISIONS[6]
          loc.accuracy  = 6
        end
      end
    end
  end
end
