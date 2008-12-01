# Geokit gem

[http://geokit.rubyforge.org](http://geokit.rubyforge.org)

## DESCRIPTION:

The Geokit gem provides the following:

 * Distance calculations between two points on the earth. Calculate the distance in miles or KM, with all the trigonometry abstracted away by GeoKit.
 * Geocoding from multiple providers. It currently supports Google, Yahoo, Geocoder.us, and Geocoder.ca geocoders, and it provides a uniform response structure from all of them. It also provides a fail-over mechanism, in case your input fails to geocode in one service.

Combine this with gem with the geokit-rails plugin to get location-based finders for your Rails app. Plugins for other web frameworks and ORMs will provide similar functionality.


## FEATURES/PROBLEMS:

* none currently

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


## REQUIREMENTS:


## INSTALL:

  * gem sources -a http://gems.github.com
  * sudo gem install

## LICENSE:

(The MIT License)

Copyright (c) 2007-2008 Andre Lewis and Bill Eisenhauer

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
