# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/geokit.rb'

# undefined method `empty?' for nil:NilClass
# /Library/Ruby/Site/1.8/rubygems/specification.rb:886:in `validate' 
class NilClass
  def empty?
    true
  end
end 

project=Hoe.new('geokit-premier', Geokit::VERSION) do |p|
  p.developer('Andrew Forward', 'aforward@gmail.com')
  p.summary="Fork of Geokit to provide for Google Premier users"
end


# vim: syntax=Ruby
