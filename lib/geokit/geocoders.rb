require 'net/http'
require 'geokit/net_adapter/net_http'
require 'geokit/net_adapter/typhoeus'
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
    @@provider_order = [:google, :us]
    @@ip_provider_order = [:geo_plugin, :ip]
    @@logger = Logger.new(STDOUT)
    @@logger.level = Logger::INFO
    @@domain = nil
    @@net_adapter = Geokit::NetAdapter::NetHttp
    @@secure = true
    @@ssl_verify_mode = OpenSSL::SSL::VERIFY_PEER

    def self.__define_accessors
      class_variables.each do |v|
        sym = v.to_s.delete('@').to_sym
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
      # Main method which calls the do_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.geocode(address, *args)
        logger.debug "#{provider_name} geocoding. address: #{address}, args #{args}"
        do_geocode(address, *args) || GeoLoc.new
      rescue TooManyQueriesError, GeocodeError
        raise
      rescue => e
        logger.error "Caught an error during #{provider_name} geocoding call: #{$!}"
        logger.error e.backtrace.join("\n")
        GeoLoc.new
      end
      # Main method which calls the do_reverse_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.reverse_geocode(latlng, *args)
        logger.debug "#{provider_name} geocoding. latlng: #{latlng}, args #{args}"
        do_reverse_geocode(latlng, *args) || GeoLoc.new
      end

      protected

      def self.logger
        Geokit::Geocoders.logger
      end

      private

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

      def self.inherited(base)
        base.config :secure
      end

      def self.new_loc
        loc = GeoLoc.new
        loc.provider = Geokit::Inflector.underscore(provider_name)
        loc
      end

      # Call the geocoder service using the timeout if configured.
      def self.call_geocoder_service(url)
        Timeout.timeout(Geokit::Geocoders.request_timeout) { return do_get(url) } if Geokit::Geocoders.request_timeout
        do_get(url)
      rescue TimeoutError
        nil
      end

      # Not all geocoders can do reverse geocoding. So, unless the subclass explicitly overrides this method,
      # a call to reverse_geocode will return an empty GeoLoc. If you happen to be using MultiGeocoder,
      # this will cause it to failover to the next geocoder, which will hopefully be one which supports reverse geocoding.
      def self.do_reverse_geocode(latlng)
        GeoLoc.new
      end

      def self.use_https?
        secure && Geokit::Geocoders.secure
      end

      def self.protocol
        use_https? ? 'https' : 'http'
      end

      # Wraps the geocoder call around a proxy if necessary.
      def self.do_get(url)
        net_adapter.do_get(url)
      end

      def self.net_adapter
        Geokit::Geocoders.net_adapter
      end

      def self.provider_name
        name.split('::').last.gsub(/Geocoder$/, '')
      end

      def self.parse(format, body, *args)
        logger.debug "#{provider_name} geocoding. Result: #{CGI.escape(body)}"
        case format
        when :json then parse_json(MultiJson.load(body), *args)
        when :xml  then parse_xml(REXML::Document.new(body), *args)
        when :yaml then parse_yaml(YAML.load(body), *args)
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
        return GeoLoc.new unless net_adapter.success?(res)
        parse format, res.body, *args
      end

      def self.transcode_to_utf8(body)
        require 'iconv' unless String.method_defined?(:encode)
        if String.method_defined?(:encode)
          body.encode!('UTF-8', 'UTF-8', invalid: :replace)
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
    Dir[File.join(File.dirname(__FILE__), '/geocoders/*.rb')].each {|f| require f}

    require File.join(File.dirname(__FILE__), 'multi_geocoder')
  end
end
