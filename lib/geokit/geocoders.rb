require 'net/http'
require 'ipaddr'
require 'rexml/document'
require 'yaml'
require 'timeout'
require 'logger'

require 'multi_json'

module Geokit
  require File.join(File.dirname(__FILE__), 'inflectors')

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
    @@proxy = nil
    @@request_timeout = nil
    @@provider_order = [:google,:us]
    @@ip_provider_order = [:geo_plugin,:ip]
    @@logger=Logger.new(STDOUT)
    @@logger.level=Logger::INFO
    @@domain = nil
    @@language = '' # defualt is english
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
    class TooManyQueriesError < StandardError; end

    # -------------------------------------------------------------------------------------------
    # Geocoder Base class -- every geocoder should inherit from this
    # -------------------------------------------------------------------------------------------

    # The Geocoder base class which defines the interface to be used by all
    # other geocoders.
    class Geocoder
      def self.config(*attrs)
        attrs.each do |attr|
          class_eval <<-METHOD
            @@#{attr} = nil
            def self.#{attr}=(value)
              @@#{attr} = value
            end
            def self.#{attr}
              @@#{attr}
            end
          METHOD
        end
      end
      # Main method which calls the do_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.geocode(address, *args)
        logger.debug "#{provider_name} geocoding. address: #{address}, args #{args}"
        do_geocode(address, *args) || GeoLoc.new
      rescue TooManyQueriesError, GeocodeError
        raise
      rescue
        logger.error "Caught an error during #{provider_name} geocoding call: #{$!}"
        GeoLoc.new
      end
      # Main method which calls the do_reverse_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.reverse_geocode(latlng)
        logger.debug "#{provider_name} geocoding. latlng: #{latlng}"
        do_reverse_geocode(latlng) || GeoLoc.new
      end

      def self.new_loc
        loc = GeoLoc.new
        loc.provider = Geokit::Inflector.underscore(provider_name)
        loc
      end

      # Call the geocoder service using the timeout if configured.
      def self.call_geocoder_service(url)
        Timeout::timeout(Geokit::Geocoders::request_timeout) { return self.do_get(url) } if Geokit::Geocoders::request_timeout
        self.do_get(url)
      rescue TimeoutError
        nil
      end

      # Not all geocoders can do reverse geocoding. So, unless the subclass explicitly overrides this method,
      # a call to reverse_geocode will return an empty GeoLoc. If you happen to be using MultiGeocoder,
      # this will cause it to failover to the next geocoder, which will hopefully be one which supports reverse geocoding.
      def self.do_reverse_geocode(latlng)
        GeoLoc.new
      end

      protected

      def self.logger
        Geokit::Geocoders::logger
      end

      private

      # Wraps the geocoder call around a proxy if necessary.
      def self.do_get(url)
        uri = URI.parse(url)
        req = Net::HTTP::Get.new(url)
        req.basic_auth(uri.user, uri.password) if uri.userinfo
        net_http_args = [uri.host, uri.port]
        if (proxy_uri_string = Geokit::Geocoders::proxy)
          proxy_uri = URI.parse(proxy_uri_string)
          net_http_args += [proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password]
        end
        Net::HTTP::new(*net_http_args).start { |http| http.request(req) }
      end

      def self.provider_name
        name.split('::').last.gsub(/Geocoder$/, '')
      end

      def self.parse(format, body, *args)
        logger.debug "#{provider_name} geocoding. Result: #{CGI.escape(body)}"
        case format
        when :json then parse_json(MultiJson.load(body), *args)
        when :xml  then parse_xml(REXML::Document.new(body), *args)
        when :yaml then parse_yaml(YAML::load(body), *args)
        when :csv  then parse_csv(body.chomp.split(','), *args)
        end
      end

      def self.set_mappings(loc, xml, mappings)
        mappings.each_pair do |field, xml_field|
          loc.send("#{field}=", xml.elements[xml_field].try(:text))
        end
      end

      def self.process(format, url, *args)
        res = call_geocoder_service(url)
        return GeoLoc.new if !res.is_a?(Net::HTTPSuccess)
        parse format, res.body, *args
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

    # -------------------------------------------------------------------------------------------
    # "Regular" Address geocoders
    # -------------------------------------------------------------------------------------------
    require File.join(File.dirname(__FILE__), 'geocoders/base_ip')
    Dir[File.join(File.dirname(__FILE__), "/geocoders/*.rb")].each {|f| require f}

    require File.join(File.dirname(__FILE__), 'multi_geocoder')
  end
end
