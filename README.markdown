# Geokit gem

[http://geokit.rubyforge.org](http://geokit.rubyforge.org)

## DESCRIPTION:

The Geokit gem provides the following:

 * Distance calculations between two points on the earth. Calculate the distance in miles or KM, with all the trigonometry abstracted away by GeoKit.
 * Geocoding from multiple providers. It currently supports Google, Yahoo, Geocoder.us, and Geocoder.ca geocoders, and it provides a uniform response structure from all of them. It also provides a fail-over mechanism, in case your input fails to geocode in one service.
 * Rectangular bounds calculations: is a point within a given rectangular bounds?
 * Heading and midpoint calculations

Combine this with gem with the [geokit-rails plugin](http://github.com/andre/geokit-rails/tree/master) to get location-based finders for your Rails app. Plugins for other web frameworks and ORMs will provide similar functionality.

## SYNOPSIS:

		irb> require 'rubygems'
		irb> require 'geokit'
		irb> a=Geokit::Geocoders::YahooGeocoder.geocode '140 Market St, San Francisco, CA'
		irb> a.ll
		 => 37.79363,-122.396116
		irb> b=Geokit::Geocoders::YahooGeocoder.geocode '789 Geary St, San Francisco, CA'
		irb> b.ll
		 => 37.786217,-122.41619
		irb> a.distance_to(b)
		 => 1.21120007413626
		irb> a.heading_to(b)
		=> 244.959832435678
		irb(main):006:0> c=a.midpoint_to(b)      # what's halfway from a to b?
		irb> c.ll
		=> "37.7899239257175,-122.406153503469"
		irb(main):008:0> d=c.endpoint(90,10)     # what's 10 miles to the east of c?
		irb> d.ll
		=> "37.7897825005142,-122.223214776155"

FYI, that `.ll` method means "latitude longitude".

## INSTALL:

  * gem sources -a http://gems.github.com
  * sudo gem install andre-geokit-gem

## Configuration

If you're using this gem by itself, here's how to set configurations:

		# These defaults are used in Geokit::Mappable.distance_to and in acts_as_mappable
		Geokit::default_units = :miles
		Geokit::default_formula = :sphere
		
		# This is the timeout value in seconds to be used for calls to the geocoder web
		# services.  For no timeout at all, comment out the setting.  The timeout unit
		# is in seconds. 
		Geokit::Geocoders::timeout = 3
		
		# These settings are used if web service calls must be routed through a proxy.
		# These setting can be nil if not needed, otherwise, addr and port must be 
		# filled in at a minimum.  If the proxy requires authentication, the username
		# and password can be provided as well.
		Geokit::Geocoders::proxy_addr = nil
		Geokit::Geocoders::proxy_port = nil
		Geokit::Geocoders::proxy_user = nil
		Geokit::Geocoders::proxy_pass = nil
		
		# This is your yahoo application key for the Yahoo Geocoder.
		# See http://developer.yahoo.com/faq/index.html#appid
		# and http://developer.yahoo.com/maps/rest/V1/geocode.html
		Geokit::Geocoders::yahoo = 'REPLACE_WITH_YOUR_YAHOO_KEY'
		    
		# This is your Google Maps geocoder key. 
		# See http://www.google.com/apis/maps/signup.html
		# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples
		Geokit::Geocoders::google = 'REPLACE_WITH_YOUR_GOOGLE_KEY'
		    
		# This is your username and password for geocoder.us.
		# To use the free service, the value can be set to nil or false.  For 
		# usage tied to an account, the value should be set to username:password.
		# See http://geocoder.us
		# and http://geocoder.us/user/signup
		Geokit::Geocoders::geocoder_us = false 
		
		# This is your authorization key for geocoder.ca.
		# To use the free service, the value can be set to nil or false.  For 
		# usage tied to an account, set the value to the key obtained from
		# Geocoder.ca.
		# See http://geocoder.ca
		# and http://geocoder.ca/?register=1
		Geokit::Geocoders::geocoder_ca = false
		
		# This is the order in which the geocoders are called in a failover scenario
		# If you only want to use a single geocoder, put a single symbol in the array.
		# Valid symbols are :google, :yahoo, :us, and :ca.
		# Be aware that there are Terms of Use restrictions on how you can use the 
		# various geocoders.  Make sure you read up on relevant Terms of Use for each
		# geocoder you are going to use.
		Geokit::Geocoders::provider_order = [:google,:us]

If you're using this gem with the [geokit-rails plugin](http://github.com/andre/geokit-rails/tree/master), a template with these settings gets placed in your app's config/initializers directory.

## NOTES ON WHAT'S WHERE

mappable.rb contains the Mappable module, which provides basic
distance calculation methods, i.e., calculating the distance
between two points. 

mappable.rb also contains LatLng, GeoLoc, and Bounds.
LatLng is a simple container for latitude and longitude, but 
it's made more powerful by mixing in the above-mentioned Mappable
module -- therefore, you can calculate easily the distance between two
LatLng ojbects with `distance = first.distance_to(other)`

GeoLoc (also in mappable.rb) represents an address or location which
has been geocoded. You can get the city, zipcode, street address, etc.
from a GeoLoc object. GeoLoc extends LatLng, so you also get lat/lng
AND the Mappable modeule goodness for free.

geocoders.rb contains all the geocoder implemenations. All the gercoders 
inherit from a common base (class Geocoder) and implement the private method
do_geocode.

## LICENSE:

(The MIT License)

Copyright (c) 2007-2009 Andre Lewis and Bill Eisenhauer

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
