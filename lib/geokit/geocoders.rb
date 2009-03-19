require 'net/http'
require 'rexml/document'
require 'yaml'
require 'timeout'
require 'logger'

module Geokit
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
    @@timeout = nil    
    @@yahoo = 'REPLACE_WITH_YOUR_YAHOO_KEY'
    @@google = 'REPLACE_WITH_YOUR_GOOGLE_KEY'
    @@geocoder_us = false
    @@geocoder_ca = false
    @@geonames = false
    @@provider_order = [:google,:us]
    @@logger=Logger.new(STDOUT)
    @@logger.level=Logger::INFO
    
    [:yahoo, :google, :geocoder_us, :geocoder_ca, :geonames, :provider_order, :timeout, 
     :proxy_addr, :proxy_port, :proxy_user, :proxy_pass,:logger].each do |sym|
      class_eval <<-EOS, __FILE__, __LINE__
        def self.#{sym}
          if defined?(#{sym.to_s.upcase})
            #{sym.to_s.upcase}
          else
            @@#{sym}
          end
        end

        def self.#{sym}=(obj)
          @@#{sym} = obj
        end
      EOS
    end
    
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
      def self.geocode(address)  
        res = do_geocode(address)
        return res.success? ? res : GeoLoc.new
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
        timeout(Geokit::Geocoders::timeout) { return self.do_get(url) } if Geokit::Geocoders::timeout        
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
                GeoKit::Geocoders::proxy_pass).start(uri.host, uri.port) { |http| http.request(req) }

        return res
      end
      
      # Adds subclass' geocode method making it conveniently available through 
      # the base class.
      def self.inherited(clazz)
        class_name = clazz.name.split('::').last
        src = <<-END_SRC
          def self.#{Geokit::Inflector.underscore(class_name)}(address)
            #{class_name}.geocode(address)
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
      def self.do_geocode(address)
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
      def self.do_geocode(address)
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
      def self.do_geocode(address)
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
      def self.do_geocode(address)
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
      def self.do_geocode(address)
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        res = self.call_geocoder_service("http://maps.google.com/maps/geo?q=#{Geokit::Inflector::url_escape(address_str)}&output=xml&key=#{Geokit::Geocoders::google}&oe=utf-8")
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        xml = res.body
        logger.debug "Google geocoding. Address: #{address}. Result: #{xml}"
        return self.xml2GeoLoc(xml, address)        
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
        else 
          logger.info "Google was unable to geocode address: "+address
          return GeoLoc.new
        end

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
        res.full_address = doc.elements['.//address'].text if doc.elements['.//address'] # google provides it
        res.zip = doc.elements['.//PostalCodeNumber'].text if doc.elements['.//PostalCodeNumber']
        res.street_address = doc.elements['.//ThoroughfareName'].text if doc.elements['.//ThoroughfareName']
        # Translate accuracy into Yahoo-style token address, street, zip, zip+4, city, state, country
        # For Google, 1=low accuracy, 8=high accuracy
        address_details=doc.elements['.//*[local-name() = "AddressDetails"]']
        accuracy = address_details ? address_details.attributes['Accuracy'].to_i : 0
        res.precision=%w{unknown country state state city zip zip+4 street address building}[accuracy]
        res.success=true
        
        return res        
      end
    end


    # -------------------------------------------------------------------------------------------
    # IP Geocoders
    # -------------------------------------------------------------------------------------------
  
    # Provides geocoding based upon an IP address.  The underlying web service is geoplugin.net
    class GeoPluginGeocoder < Geocoder
      private
      
      def self.do_geocode(ip)
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        response = self.call_geocoder_service("http://www.geoplugin.net/xml.gp?ip=#{ip}")
        return response.is_a?(Net::HTTPSuccess) ? parse_xml(response.body) : GeoLoc.new
      rescue
        logger.error "Caught an error during GeloPluginGeocoder geocoding call: "+$!
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
        geo.success = !geo.city.empty?
        return geo
      end
    end

    # Provides geocoding based upon an IP address.  The underlying web service is a hostip.info
    # which sources their data through a combination of publicly available information as well
    # as community contributions.
    class IpGeocoder < Geocoder 

      private 

      # Given an IP address, returns a GeoLoc instance which contains latitude,
      # longitude, city, and country code.  Sets the success attribute to false if the ip 
      # parameter does not match an ip address.  
      def self.do_geocode(ip)
        return GeoLoc.new if '0.0.0.0' == ip
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
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
    end
    
    # -------------------------------------------------------------------------------------------
    # The Multi Geocoder
    # -------------------------------------------------------------------------------------------    
    
    # Provides methods to geocode with a variety of geocoding service providers, plus failover
    # among providers in the order you configure.
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
      def self.do_geocode(address)
        Geokit::Geocoders::provider_order.each do |provider|
          begin
            klass = Geokit::Geocoders.const_get "#{provider.to_s.capitalize}Geocoder"
            res = klass.send :geocode, address
            return res if res.success?
          rescue
            logger.error("Something has gone very wrong during geocoding, OR you have configured an invalid class name in Geokit::Geocoders::provider_order. Address: #{address}. Provider: #{provider}")
          end
        end
        # If we get here, we failed completely.
        GeoLoc.new
      end
    end   
  end
end
