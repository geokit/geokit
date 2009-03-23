module Geokit
  module GeocoderControl
    def set_geokit_domain
      Geokit::Geocoders::domain = request.domain
      logger.debug("Geokit is using the domain: #{Geokit::Geocoders::domain}")
    end
  
    def self.included(base)
      if base.respond_to? :before_filter
        base.send :before_filter, :set_geokit_domain
      end
    end
  end
end

ActionController::Base.send(:include, Geokit::GeocoderControl) if defined?(ActionController::Base)