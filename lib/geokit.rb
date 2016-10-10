module Geokit
  # These defaults are used in Geokit::Mappable.distance_to and in acts_as_mappable
  @@default_units   = :miles
  @@default_formula = :sphere

  [:default_units, :default_formula].each do |sym|
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
end

path = File.expand_path(File.dirname(__FILE__))
$:.unshift path unless $:.include?(path)
require 'geokit/core_ext'
require 'geokit/geocoders'
require 'geokit/mappable'
require 'geokit/bounds'
require 'geokit/lat_lng'
require 'geokit/geo_loc'
require 'geokit/polygon'
