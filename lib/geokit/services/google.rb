module Geokit
  module Geocoders
    # -------------------------------------------------------------------------------------------
    # Address geocoders that also provide reverse geocoding
    # -------------------------------------------------------------------------------------------

    # Google geocoder implementation.  Requires the Geokit::Geocoders::GOOGLE variable to
    # contain a Google API key.  Conforms to the interface set by the Geocoder class.
    class GoogleGeocoder < Geocoder

      private

      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng)
        latlng=LatLng.normalize(latlng)
        res = self.call_geocoder_service("http://maps.google.com/maps/geo?ll=#{Geokit::Inflector::url_escape(latlng.ll)}&output=xml&key=#{Geokit::Geocoders::google}&oe=utf-8")
        #        res = Net::HTTP.get_response(URI.parse("http://maps.google.com/maps/geo?ll=#{Geokit::Inflector::url_escape(address_str)}&output=xml&key=#{Geokit::Geocoders::google}&oe=utf-8"))
        return GeoLoc.new unless (res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPOK))
        xml = self.transcode_to_utf8(res.body)
        logger.debug "Google reverse-geocoding. LL: #{latlng}. Result: #{xml}"
        return self.xml2GeoLoc(xml)
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
        res = self.call_geocoder_service("http://maps.google.com/maps/geo?q=#{Geokit::Inflector::url_escape(address_str)}&output=xml#{bias_str}&key=#{Geokit::Geocoders::google}&oe=utf-8")
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        xml = self.transcode_to_utf8(res.body)
        logger.debug "Google geocoding. Address: #{address}. Result: #{xml}"
        return self.xml2GeoLoc(xml, address)
      end

      def self.construct_bias_string_from_options(bias)
        if bias.is_a?(String) or bias.is_a?(Symbol)
          # country code biasing
          "&gl=#{bias.to_s.downcase}"
        elsif bias.is_a?(Bounds)
          # viewport biasing
          "&ll=#{bias.center.ll}&spn=#{bias.to_span.ll}"
        end
      end

      def self.xml2GeoLoc(xml, address="")
        doc=REXML::Document.new(xml)

        if doc.elements['//kml/Response/Status/code'].text == '200'
          geoloc = nil
          # Google can return multiple results as //Placemark elements.
          # iterate through each and extract each placemark as a geoloc
          doc.each_element('//Placemark') do |e|
            extracted_geoloc = extract_placemark(e) # g is now an instance of GeoLoc
            if geoloc.nil?
              # first time through, geoloc is still nil, so we make it the geoloc we just extracted
              geoloc = extracted_geoloc
            else
              # second (and subsequent) iterations, we push additional
              # geolocs onto "geoloc.all"
              geoloc.all.push(extracted_geoloc)
            end
          end
          return geoloc
        elsif doc.elements['//kml/Response/Status/code'].text == '620'
          raise Geokit::TooManyQueriesError
        else
          logger.info "Google was unable to geocode address: "+address
          return GeoLoc.new
        end

      rescue Geokit::TooManyQueriesError
        # re-raise because of other rescue
        raise Geokit::TooManyQueriesError, "Google returned a 620 status, too many queries. The given key has gone over the requests limit in the 24 hour period or has submitted too many requests in too short a period of time. If you're sending multiple requests in parallel or in a tight loop, use a timer or pause in your code to make sure you don't send the requests too quickly."
      rescue
        logger.error "Caught an error during Google geocoding call: "+$!
        return GeoLoc.new
      end

      # extracts a single geoloc from a //placemark element in the google results xml
      def self.extract_placemark(doc)
        res = GeoLoc.new
        coordinates=doc.elements['.//coordinates'].text.to_s.split(',')

        #basics
        res.lat=coordinates[1]
        res.lng=coordinates[0]
        res.country_code=doc.elements['.//CountryNameCode'].text if doc.elements['.//CountryNameCode']
        res.provider='google'

        #extended -- false if not not available
        res.city = doc.elements['.//LocalityName'].text if doc.elements['.//LocalityName']
        res.state = doc.elements['.//AdministrativeAreaName'].text if doc.elements['.//AdministrativeAreaName']
        res.province = doc.elements['.//SubAdministrativeAreaName'].text if doc.elements['.//SubAdministrativeAreaName']
        res.full_address = doc.elements['.//address'].text if doc.elements['.//address'] # google provides it
        res.zip = doc.elements['.//PostalCodeNumber'].text if doc.elements['.//PostalCodeNumber']
        res.street_address = doc.elements['.//ThoroughfareName'].text if doc.elements['.//ThoroughfareName']
        res.country = doc.elements['.//CountryName'].text if doc.elements['.//CountryName']
        res.district = doc.elements['.//DependentLocalityName'].text if doc.elements['.//DependentLocalityName']
        # Translate accuracy into Yahoo-style token address, street, zip, zip+4, city, state, country
        # For Google, 1=low accuracy, 8=high accuracy
        address_details=doc.elements['.//*[local-name() = "AddressDetails"]']
        res.accuracy = address_details ? address_details.attributes['Accuracy'].to_i : 0
        res.precision=%w{unknown country state state city zip zip+4 street address building}[res.accuracy]

        # google returns a set of suggested boundaries for the geocoded result
        if suggested_bounds = doc.elements['//LatLonBox']
          res.suggested_bounds = Bounds.normalize(
            [suggested_bounds.attributes['south'], suggested_bounds.attributes['west']],
            [suggested_bounds.attributes['north'], suggested_bounds.attributes['east']])
        end

        res.success=true

        return res
      end
      
      def self.transcode_to_utf8(body)
        require 'iconv' unless String.method_defined?(:encode)
        if String.method_defined?(:encode)
          body.encode!('UTF-8', 'UTF-8', :invalid => :replace)
        else
          ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
          body = ic.iconv(body)
        end        
      end
    end
  end
end
