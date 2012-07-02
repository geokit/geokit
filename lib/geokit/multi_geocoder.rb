module Geokit
  module Geocoders
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
          rescue => e
            logger.error("An error has occurred during geocoding: #{e}\nAddress: #{address}. Provider: #{provider}")
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
          rescue => e
            logger.error("An error has occurred during geocoding: #{e}\nLatlng: #{latlng}. Provider: #{provider}")
          end
        end
        # If we get here, we failed completely.
        GeoLoc.new
      end
    end
  end
end

