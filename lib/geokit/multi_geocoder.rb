module Geokit
  module Geocoders
    # --------------------------------------------------------------------------
    # The Multi Geocoder
    # --------------------------------------------------------------------------

    # Provides methods to geocode with a variety of geocoding service providers,
    # plus failover among providers in the order you configure. When 2nd
    # parameter is set 'true', perform ip location lookup with 'address' as the
    # ip address.
    #
    # Goal:
    # - homogenize the results of multiple geocoders
    #
    # Limitations:
    # - currently only provides the first result. Sometimes geocoders will
    #   return multiple results.
    # - currently discards the "accuracy" component of the geocoding calls
    class MultiGeocoder < Geocoder
      private

      # This method will call one or more geocoders in the order specified in
      # the configuration until one of the geocoders work.
      #
      # The failover approach is crucial for production-grade apps, but is
      # rarely used.
      # 98% of your geocoding calls will be successful with the first call
      def self.do_geocode(address, *args)
        provider_order = provider_order_for(address, args)

        provider_order.each do |provider|
          klass = geocoder(provider)
          begin
            res = klass.send :geocode, address, *args
            return res if res.success?
          rescue => e
            logger.error("An error has occurred during geocoding: #{e}\n" +
                         "Address: #{address}. Provider: #{provider}")
          end
        end
        # If we get here, we failed completely.
        GeoLoc.new
      end

      # This method will call one or more geocoders in the order specified in
      # the configuration until one of the geocoders work, only this time it's
      # going to try to reverse geocode a geographical point.
      def self.do_reverse_geocode(latlng)
        Geokit::Geocoders.provider_order.each do |provider|
          klass = geocoder(provider)
          begin
            res = klass.send :reverse_geocode, latlng
            return res if res.success?
          rescue => e
            logger.error("An error has occurred during geocoding: #{e}\n" +
                         "Latlng: #{latlng}. Provider: #{provider}")
          end
        end
        # If we get here, we failed completely.
        GeoLoc.new
      end

      def self.geocoder(provider)
        class_name = "#{Geokit::Inflector.camelize(provider.to_s)}Geocoder"
        Geokit::Geocoders.const_get class_name
      end

      def self.provider_order_for(address, args)
        if args.last.is_a?(Hash) && args.last.key?(:provider_order)
          args.last.delete(:provider_order)
        else
          if /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/.match(address)
            Geokit::Geocoders.ip_provider_order
          else
            Geokit::Geocoders.provider_order
          end
        end
      end
    end
  end
end
