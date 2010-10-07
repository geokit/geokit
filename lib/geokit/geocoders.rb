require 'net/http'
require 'ipaddr'
require 'rexml/document'
require 'yaml'
require 'timeout'
require 'logger'

# do this just in case 
begin 
  ActiveSupport.nil?
rescue NameError
  require 'json/pure'
end

module Geokit

  class TooManyQueriesError < StandardError; end

  module Inflector
   
    extend self
   
    def titleize(word)
      humanize(underscore(word)).gsub(/\b([a-z])/u) { $1.capitalize }
    end
   
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/u,'\1_\2').
      gsub(/([a-z\d])([A-Z])/u,'\1_\2').
      tr("-", "_").
      downcase
    end
   
    def humanize(lower_case_and_underscored_word)
      lower_case_and_underscored_word.to_s.gsub(/_id$/, "").gsub(/_/, " ").capitalize
    end
    
    def snake_case(s)
      return s.downcase if s =~ /^[A-Z]+$/u
      s.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/u, '_\&') =~ /_*(.*)/
        return $+.downcase
      
    end
    
    def url_escape(s)
    s.gsub(/([^ a-zA-Z0-9_.-]+)/nu) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
      end.tr(' ', '+')
    end
    
    def camelize(str)
      str.split('_').map {|w| w.capitalize}.join
    end
  end  
  
  # Contains a range of geocoders:
  # 
  # ### "regular" address geocoders 
  # * Yahoo Geocoder - requires an API key.
  # * Geocoder.us - may require authentication if performing more than the free request limit.
  # * Geocoder.ca - for Canada; may require authentication as well.
  # * Geonames - a free geocoder
  #
  # ### address geocoders that also provide reverse geocoding 
  # * Google Geocoder - requires an API key.
  #  
  # ### IP address geocoders 
  # * IP Geocoder - geocodes an IP address using hostip.info's web service.
  # * Geoplugin.net -- another IP address geocoder
  #
  # ### The Multigeocoder
  # * Multi Geocoder - provides failover for the physical location geocoders.
  # 
  # Some of these geocoders require configuration. You don't have to provide it here. See the README.
  module Geocoders
    @@proxy_addr = nil
    @@proxy_port = nil
    @@proxy_user = nil
    @@proxy_pass = nil
    @@request_timeout = nil    
    @@yahoo = 'REPLACE_WITH_YOUR_YAHOO_KEY'
    @@google = 'REPLACE_WITH_YOUR_GOOGLE_KEY'
    @@geocoder_us = false
    @@geocoder_ca = false
    @@geonames = false
    @@provider_order = [:google,:us]
    @@ip_provider_order = [:geo_plugin,:ip]
    @@logger=Logger.new(STDOUT)
    @@logger.level=Logger::INFO
    @@domain = nil
    
    def self.__define_accessors
      class_variables.each do |v| 
        sym = v.to_s.delete("@").to_sym
        unless self.respond_to? sym
          module_eval <<-EOS, __FILE__, __LINE__
            def self.#{sym}
              value = if defined?(#{sym.to_s.upcase})
                #{sym.to_s.upcase}
              else
                @@#{sym}
              end
              if value.is_a?(Hash)
                value = (self.domain.nil? ? nil : value[self.domain]) || value.values.first
              end
              value
            end
          
            def self.#{sym}=(obj)
              @@#{sym} = obj
            end
          EOS
        end
      end
    end

    __define_accessors
    
    # Error which is thrown in the event a geocoding error occurs.
    class GeocodeError < StandardError; end

    # -------------------------------------------------------------------------------------------
    # Geocoder Base class -- every geocoder should inherit from this
    # -------------------------------------------------------------------------------------------    
    
    # The Geocoder base class which defines the interface to be used by all
    # other geocoders.
    class Geocoder   
      # Main method which calls the do_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.geocode(address, options = {}) 
        res = do_geocode(address, options)
        return res.nil? ? GeoLoc.new : res
      end  
      # Main method which calls the do_reverse_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.reverse_geocode(latlng)
        res = do_reverse_geocode(latlng)
        return res.success? ? res : GeoLoc.new        
      end
      
      # Call the geocoder service using the timeout if configured.
      def self.call_geocoder_service(url)
        Timeout::timeout(Geokit::Geocoders::request_timeout) { return self.do_get(url) } if Geokit::Geocoders::request_timeout        
        return self.do_get(url)
      rescue TimeoutError
        return nil  
      end

      # Not all geocoders can do reverse geocoding. So, unless the subclass explicitly overrides this method,
      # a call to reverse_geocode will return an empty GeoLoc. If you happen to be using MultiGeocoder,
      # this will cause it to failover to the next geocoder, which will hopefully be one which supports reverse geocoding.
      def self.do_reverse_geocode(latlng)
        return GeoLoc.new
      end

      protected

      def self.logger() 
        Geokit::Geocoders::logger
      end
      
      private
      
      # Wraps the geocoder call around a proxy if necessary.
      def self.do_get(url) 
        uri = URI.parse(url)
        req = Net::HTTP::Get.new(url)
        req.basic_auth(uri.user, uri.password) if uri.userinfo
        res = Net::HTTP::Proxy(GeoKit::Geocoders::proxy_addr,
                GeoKit::Geocoders::proxy_port,
                GeoKit::Geocoders::proxy_user,
                GeoKit::Geocoders::proxy_pass).start(uri.host, uri.port) { |http| http.get(uri.path + "?" + uri.query) }
        return res
      end
      
      # Adds subclass' geocode method making it conveniently available through 
      # the base class.
      def self.inherited(clazz)
        class_name = clazz.name.split('::').last
        src = <<-END_SRC
          def self.#{Geokit::Inflector.underscore(class_name)}(address, options = {})
            #{class_name}.geocode(address, options)
          end
        END_SRC
        class_eval(src)
      end
    end

    # -------------------------------------------------------------------------------------------
    # "Regular" Address geocoders
    # -------------------------------------------------------------------------------------------    
    
    # Geocoder CA geocoder implementation.  Requires the Geokit::Geocoders::GEOCODER_CA variable to
    # contain true or false based upon whether authentication is to occur.  Conforms to the 
    # interface set by the Geocoder class.
    #
    # Returns a response like:
    # <?xml version="1.0" encoding="UTF-8" ?>
    # <geodata>
    #   <latt>49.243086</latt>
    #   <longt>-123.153684</longt>
    # </geodata>
    class CaGeocoder < Geocoder

      private

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        raise ArgumentError('Geocoder.ca requires a GeoLoc argument') unless address.is_a?(GeoLoc)
        url = construct_request(address)
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        xml = res.body
        logger.debug "Geocoder.ca geocoding. Address: #{address}. Result: #{xml}"
        # Parse the document.
        doc = REXML::Document.new(xml)    
        address.lat = doc.elements['//latt'].text
        address.lng = doc.elements['//longt'].text
        address.success = true
        return address
      rescue
        logger.error "Caught an error during Geocoder.ca geocoding call: "+$!
        return GeoLoc.new  
      end  

      # Formats the request in the format acceptable by the CA geocoder.
      def self.construct_request(location)
        url = ""
        url += add_ampersand(url) + "stno=#{location.street_number}" if location.street_address
        url += add_ampersand(url) + "addresst=#{Geokit::Inflector::url_escape(location.street_name)}" if location.street_address
        url += add_ampersand(url) + "city=#{Geokit::Inflector::url_escape(location.city)}" if location.city
        url += add_ampersand(url) + "prov=#{location.state}" if location.state
        url += add_ampersand(url) + "postal=#{location.zip}" if location.zip
        url += add_ampersand(url) + "auth=#{Geokit::Geocoders::geocoder_ca}" if Geokit::Geocoders::geocoder_ca
        url += add_ampersand(url) + "geoit=xml"
        'http://geocoder.ca/?' + url
      end

      def self.add_ampersand(url)
        url && url.length > 0 ? "&" : ""
      end
    end    
    
    # Geocoder Us geocoder implementation.  Requires the Geokit::Geocoders::GEOCODER_US variable to
    # contain true or false based upon whether authentication is to occur.  Conforms to the 
    # interface set by the Geocoder class.
    class UsGeocoder < Geocoder

      private
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        
        query = (address_str =~ /^\d{5}(?:-\d{4})?$/ ? "zip" : "address") + "=#{Geokit::Inflector::url_escape(address_str)}"
        url = if GeoKit::Geocoders::geocoder_us         
          "http://#{GeoKit::Geocoders::geocoder_us}@geocoder.us/member/service/csv/geocode"
        else
          "http://geocoder.us/service/csv/geocode"
        end
        
        url = "#{url}?#{query}"  
        res = self.call_geocoder_service(url)
        
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        data = res.body
        logger.debug "Geocoder.us geocoding. Address: #{address}. Result: #{data}"
        array = data.chomp.split(',')
        
        if array.length == 5
          res=GeoLoc.new
          res.lat,res.lng,res.city,res.state,res.zip=array
          res.country_code='US'
          res.success=true
          return res
        elsif array.length == 6  
          res=GeoLoc.new 
          res.lat,res.lng,res.street_address,res.city,res.state,res.zip=array
          res.country_code='US'
          res.success=true 
          return res
        else 
          logger.info "geocoder.us was unable to geocode address: "+address
          return GeoLoc.new      
        end
        rescue 
          logger.error "Caught an error during geocoder.us geocoding call: "+$!
          return GeoLoc.new

      end
    end
    
    # Yahoo geocoder implementation.  Requires the Geokit::Geocoders::YAHOO variable to
    # contain a Yahoo API key.  Conforms to the interface set by the Geocoder class.
    class YahooGeocoder < Geocoder

      private 

      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        url="http://api.local.yahoo.com/MapsService/V1/geocode?appid=#{Geokit::Geocoders::yahoo}&location=#{Geokit::Inflector::url_escape(address_str)}"
        res = self.call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        xml = res.body
        doc = REXML::Document.new(xml)
        logger.debug "Yahoo geocoding. Address: #{address}. Result: #{xml}"

        if doc.elements['//ResultSet']
          res=GeoLoc.new

          #basic      
          res.lat=doc.elements['//Latitude'].text
          res.lng=doc.elements['//Longitude'].text
          res.country_code=doc.elements['//Country'].text
          res.provider='yahoo'  

          #extended - false if not available
          res.city=doc.elements['//City'].text if doc.elements['//City'] && doc.elements['//City'].text != nil
          res.state=doc.elements['//State'].text if doc.elements['//State'] && doc.elements['//State'].text != nil
          res.zip=doc.elements['//Zip'].text if doc.elements['//Zip'] && doc.elements['//Zip'].text != nil
          res.street_address=doc.elements['//Address'].text if doc.elements['//Address'] && doc.elements['//Address'].text != nil
          res.precision=doc.elements['//Result'].attributes['precision'] if doc.elements['//Result']
          # set the accuracy as google does (added by Andruby)
          res.accuracy=%w{unknown country state state city zip zip+4 street address building}.index(res.precision)
          res.success=true
          return res
        else 
          logger.info "Yahoo was unable to geocode address: "+address
          return GeoLoc.new
        end   

        rescue 
          logger.info "Caught an error during Yahoo geocoding call: "+$!
          return GeoLoc.new
      end
    end

    # Another geocoding web service
    # http://www.geonames.org
    class GeonamesGeocoder < Geocoder

      private 
      
      # Template method which does the geocode lookup.
      def self.do_geocode(address, options = {})
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        # geonames need a space seperated search string
        address_str.gsub!(/,/, " ")
        params = "/postalCodeSearch?placename=#{Geokit::Inflector::url_escape(address_str)}&maxRows=10"
        
        if(GeoKit::Geocoders::geonames)
          url = "http://ws.geonames.net#{params}&username=#{GeoKit::Geocoders::geonames}"
        else
          url = "http://ws.geonames.org#{params}"
        end
        
        res = self.call_geocoder_service(url)
        
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        
        xml=res.body
        logger.debug "Geonames geocoding. Address: #{address}. Result: #{xml}"
        doc=REXML::Document.new(xml)
        
        if(doc.elements['//geonames/totalResultsCount'].text.to_i > 0)
          res=GeoLoc.new
        
          # only take the first result
          res.lat=doc.elements['//code/lat'].text if doc.elements['//code/lat']
          res.lng=doc.elements['//code/lng'].text if doc.elements['//code/lng']
          res.country_code=doc.elements['//code/countryCode'].text if doc.elements['//code/countryCode']
          res.provider='genomes'  
          res.city=doc.elements['//code/name'].text if doc.elements['//code/name']
          res.state=doc.elements['//code/adminName1'].text if doc.elements['//code/adminName1']
          res.zip=doc.elements['//code/postalcode'].text if doc.elements['//code/postalcode']
          res.success=true
          return res
        else 
          logger.info "Geonames was unable to geocode address: "+address
          return GeoLoc.new
        end
        
        rescue
          logger.error "Caught an error during Geonames geocoding call: "+$!
      end
    end

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
        xml = res.body
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
        xml = res.body
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
    end

    class GoogleGeocoder3 < Geocoder

      private 
      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng) 
        latlng=LatLng.normalize(latlng)
        res = self.call_geocoder_service("http://maps.google.com/maps/api/geocode/json?sensor=false&latlng=#{Geokit::Inflector::url_escape(latlng.ll)}")
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
        res = self.call_geocoder_service("http://maps.google.com/maps/api/geocode/json?sensor=false&address=#{Geokit::Inflector::url_escape(address_str)}#{bias_str}")
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        json = res.body
        logger.debug "Google geocoding. Address: #{address}. Result: #{json}"
        return self.json2GeoLoc(json, address)        
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
        begin
          results=::ActiveSupport::JSON.decode(json)
        rescue NameError => e
          results=JSON.parse(json)
        end
          
        
        if results['status'] == 'OVER_QUERY_LIMIT'
          raise Geokit::TooManyQueriesError
        end
        if results['status'] == 'ZERO_RESULTS'
          return GeoLoc.new
        end
        # this should probably be smarter.
        if !results['status'] == 'OK'
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
        results['results'].sort_by{|a|accuracy[a['geometry']['location_type']]}.reverse.each do |addr|
          res=GeoLoc.new
          res.provider = 'google3'
          res.success = true
          res.full_address = addr['formatted_address']
          addr['address_components'].each do |comp|
            case
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
            end
          end
          if res.street_name
            res.street_address=[res.street_number,res.street_name].join(' ').strip
          end
          res.accuracy = accuracy[addr['geometry']['location_type']]
          res.precision=%w{unknown country state state city zip zip+4 street address building}[res.accuracy]
          # try a few overrides where we can
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

          if ret
            ret.all.push(res)
          else
            ret=res
          end
        end
        return ret
      end
    end
    
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
         ret=nil
         begin
           results=::ActiveSupport::JSON.decode(json)
         rescue NameError => e
           results=JSON.parse(json)
         end
         
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
    # -------------------------------------------------------------------------------------------
    # IP Geocoders
    # -------------------------------------------------------------------------------------------
  
    # Provides geocoding based upon an IP address.  The underlying web service is geoplugin.net
    class GeoPluginGeocoder < Geocoder
      private
      
      def self.do_geocode(ip, options = {})
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        response = self.call_geocoder_service("http://www.geoplugin.net/xml.gp?ip=#{ip}")
        return response.is_a?(Net::HTTPSuccess) ? parse_xml(response.body) : GeoLoc.new
      rescue
        logger.error "Caught an error during GeoPluginGeocoder geocoding call: "+$!
        return GeoLoc.new
      end

      def self.parse_xml(xml)
        xml = REXML::Document.new(xml)
        geo = GeoLoc.new
        geo.provider='geoPlugin'
        geo.city = xml.elements['//geoplugin_city'].text
        geo.state = xml.elements['//geoplugin_region'].text
        geo.country_code = xml.elements['//geoplugin_countryCode'].text
        geo.lat = xml.elements['//geoplugin_latitude'].text.to_f
        geo.lng = xml.elements['//geoplugin_longitude'].text.to_f
        geo.success = !!geo.city && !geo.city.empty?
        return geo
      end
    end

    # Provides geocoding based upon an IP address.  The underlying web service is a hostip.info
    # which sources their data through a combination of publicly available information as well
    # as community contributions.
    class IpGeocoder < Geocoder 

      # A number of non-routable IP ranges.
      #
      # --
      # Sources for these:
      #   RFC 3330: Special-Use IPv4 Addresses
      #   The bogon list: http://www.cymru.com/Documents/bogon-list.html

      NON_ROUTABLE_IP_RANGES = [
	IPAddr.new('0.0.0.0/8'),      # "This" Network
	IPAddr.new('10.0.0.0/8'),     # Private-Use Networks
	IPAddr.new('14.0.0.0/8'),     # Public-Data Networks
	IPAddr.new('127.0.0.0/8'),    # Loopback
	IPAddr.new('169.254.0.0/16'), # Link local
	IPAddr.new('172.16.0.0/12'),  # Private-Use Networks
	IPAddr.new('192.0.2.0/24'),   # Test-Net
	IPAddr.new('192.168.0.0/16'), # Private-Use Networks
	IPAddr.new('198.18.0.0/15'),  # Network Interconnect Device Benchmark Testing
	IPAddr.new('224.0.0.0/4'),    # Multicast
	IPAddr.new('240.0.0.0/4')     # Reserved for future use
      ].freeze

      private 

      # Given an IP address, returns a GeoLoc instance which contains latitude,
      # longitude, city, and country code.  Sets the success attribute to false if the ip 
      # parameter does not match an ip address.  
      def self.do_geocode(ip, options = {})
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        return GeoLoc.new if self.private_ip_address?(ip)
        url = "http://api.hostip.info/get_html.php?ip=#{ip}&position=true"
        response = self.call_geocoder_service(url)
        response.is_a?(Net::HTTPSuccess) ? parse_body(response.body) : GeoLoc.new
      rescue
        logger.error "Caught an error during HostIp geocoding call: "+$!
        return GeoLoc.new
      end

      # Converts the body to YAML since its in the form of:
      #
      # Country: UNITED STATES (US)
      # City: Sugar Grove, IL
      # Latitude: 41.7696
      # Longitude: -88.4588
      #
      # then instantiates a GeoLoc instance to populate with location data.
      def self.parse_body(body) # :nodoc:
        yaml = YAML.load(body)
        res = GeoLoc.new
        res.provider = 'hostip'
        res.city, res.state = yaml['City'].split(', ')
        country, res.country_code = yaml['Country'].split(' (')
        res.lat = yaml['Latitude'] 
        res.lng = yaml['Longitude']
        res.country_code.chop!
        res.success = !(res.city =~ /\(.+\)/)
        res
      end

      # Checks whether the IP address belongs to a private address range.
      #
      # This function is used to reduce the number of useless queries made to
      # the geocoding service. Such queries can occur frequently during
      # integration tests.
      def self.private_ip_address?(ip)
	return NON_ROUTABLE_IP_RANGES.any? { |range| range.include?(ip) }
      end
    end
    
    # -------------------------------------------------------------------------------------------
    # The Multi Geocoder
    # -------------------------------------------------------------------------------------------    
    
    # Provides methods to geocode with a variety of geocoding service providers, plus failover
    # among providers in the order you configure. When 2nd parameter is set 'true', perform
    # ip location lookup with 'address' as the ip address.
    # 
    # Goal:
    # - homogenize the results of multiple geocoders
    # 
    # Limitations:
    # - currently only provides the first result. Sometimes geocoders will return multiple results.
    # - currently discards the "accuracy" component of the geocoding calls
    class MultiGeocoder < Geocoder       

      private
      # This method will call one or more geocoders in the order specified in the 
      # configuration until one of the geocoders work.
      # 
      # The failover approach is crucial for production-grade apps, but is rarely used.
      # 98% of your geocoding calls will be successful with the first call  
      def self.do_geocode(address, options = {})
        geocode_ip = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/.match(address)
        provider_order = geocode_ip ? Geokit::Geocoders::ip_provider_order : Geokit::Geocoders::provider_order
        
        provider_order.each do |provider|
          begin
            klass = Geokit::Geocoders.const_get "#{Geokit::Inflector::camelize(provider.to_s)}Geocoder"
            res = klass.send :geocode, address, options
            return res if res.success?
          rescue
            logger.error("Something has gone very wrong during geocoding, OR you have configured an invalid class name in Geokit::Geocoders::provider_order. Address: #{address}. Provider: #{provider}")
          end
        end
        # If we get here, we failed completely.
        GeoLoc.new
      end
      
      # This method will call one or more geocoders in the order specified in the 
      # configuration until one of the geocoders work, only this time it's going
      # to try to reverse geocode a geographical point.
      def self.do_reverse_geocode(latlng)
        Geokit::Geocoders::provider_order.each do |provider|
          begin
            klass = Geokit::Geocoders.const_get "#{Geokit::Inflector::camelize(provider.to_s)}Geocoder"
            res = klass.send :reverse_geocode, latlng
            return res if res.success?
          rescue
            logger.error("Something has gone very wrong during reverse geocoding, OR you have configured an invalid class name in Geokit::Geocoders::provider_order. LatLng: #{latlng}. Provider: #{provider}")
          end
        end
        # If we get here, we failed completely.
        GeoLoc.new
      end
    end   
  end
end
