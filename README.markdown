Geokit
======

[![Gem Version](https://badge.fury.io/rb/geokit.png)](http://badge.fury.io/rb/geokit)
[![Build Status](https://travis-ci.org/geokit/geokit.png?branch=master)](https://travis-ci.org/geokit/geokit)
[![Coverage Status](https://coveralls.io/repos/geokit/geokit/badge.png)](https://coveralls.io/r/geokit/geokit)
[![Dependency Status](https://gemnasium.com/geokit/geokit.png)](https://gemnasium.com/geokit/geokit)
[![Code Climate](https://codeclimate.com/github/geokit/geokit.png)](https://codeclimate.com/github/geokit/geokit)

## DESCRIPTION

The Geokit gem provides:

 * Distance calculations between two points on the earth. Calculate the distance in miles, kilometers, meters, or nautical miles, with all the trigonometry abstracted away by Geokit.
 * Geocoding from multiple providers. It supports Google, Yahoo, Geocoder.us, and Geocoder.ca geocoders, and others. It provides a uniform response structure from all of them.
   It also provides a fail-over mechanism, in case your input fails to geocode in one service.
 * Rectangular bounds calculations: is a point within a given rectangular bounds?
 * Heading and midpoint calculations

Combine this gem with the [geokit-rails](http://github.com/geokit/geokit-rails) to get location-based finders for your Rails app.

* Repository at Github: [http://github.com/geokit/geokit](http://github.com/geokit/geokit).
* RDoc pages: [http://rdoc.info/github/geokit/geokit/master/frames](http://rdoc.info/github/geokit/geokit/master/frames)

## COMMUNICATION

* If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/geokit). (Tag 'geokit' and we'll be alerted)
* If you **found a bug**, use GitHub issues.
* If you **have an idea**, use GitHub issues.
* If you'd like to **ask a general question**, use GitHub issues.
* If you **want to contribute**, submit a pull request.

## INSTALL

    gem install geokit

## SUPPORTED GEOCODERS

### "regular" address geocoders
* Yahoo BOSS - requires an API key.
* Geocoder.us - may require authentication if performing more than the free request limit.
* Geocoder.ca - for Canada; may require authentication as well.
* Geonames - a free geocoder
* Bing
* Yandex
* MapQuest
* Geocod.io
* Mapbox - requires an access token
* [OpenCage](http://geocoder.opencagedata.com) - requires an API key

### address geocoders that also provide reverse geocoding
* Google - Supports multiple results and bounding box/country code biasing.  Also supports Maps API for Business keys; see the configuration section below.
* FCC
* OpenStreetMap
* Mapbox
* OpenCage

### IP address geocoders
* IP - geocodes an IP address using hostip.info's web service.
* Geoplugin.net -- another IP address geocoder
* RIPE
* MaxMind
* freegeoip.net

### HTTPS-supporting geocoders
* Google
* Yahoo
* Bing
* FCC
* MapQuest
* Mapbox
* OpenCage

Options to control the use of HTTPS are described below in the Configuration section.

## QUICK START

```ruby
    irb> require 'rubygems'
    irb> require 'geokit'
    irb> a=Geokit::Geocoders::GoogleGeocoder.geocode '140 Market St, San Francisco, CA'
    irb> a.ll
     => 37.79363,-122.396116
    irb> b=Geokit::Geocoders::GoogleGeocoder.geocode '789 Geary St, San Francisco, CA'
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
```

FYI, that `.ll` method means "latitude longitude".

See the RDOC more more ... there are also operations on rectangular bounds (e.g., determining if a point is within bounds, find the center, etc).

## CONFIGURATION

If you're using this gem by itself, here are the configuration options:

```ruby
    # These defaults are used in Geokit::Mappable.distance_to and in acts_as_mappable
    Geokit::default_units = :miles # others :kms, :nms, :meters
    Geokit::default_formula = :sphere

    # This is the timeout value in seconds to be used for calls to the geocoder web
    # services.  For no timeout at all, comment out the setting.  The timeout unit
    # is in seconds.
    Geokit::Geocoders::request_timeout = 3

    # This setting can be used if web service calls must be routed through a proxy.
    # These setting can be nil if not needed, otherwise, a valid URI must be
    # filled in at a minimum.  If the proxy requires authentication, the username
    # and password can be provided as well.
    Geokit::Geocoders::proxy = 'https://user:password@host:port'

    # This is your yahoo application key for the Yahoo Geocoder.
    # See http://developer.yahoo.com/faq/index.html#appid
    # and http://developer.yahoo.com/maps/rest/V1/geocode.html
    Geokit::Geocoders::YahooGeocoder.key = 'REPLACE_WITH_YOUR_YAHOO_KEY'
    Geokit::Geocoders::YahooGeocoder.secret = 'REPLACE_WITH_YOUR_YAHOO_SECRET'

    # This is your Google Maps geocoder keys (all optional).
    # See http://www.google.com/apis/maps/signup.html
    # and http://www.google.com/apis/maps/documentation/#Geocoding_Examples
    Geokit::Geocoders::GoogleGeocoder.client_id = ''
    Geokit::Geocoders::GoogleGeocoder.cryptographic_key = ''
    Geokit::Geocoders::GoogleGeocoder.channel = ''

    # You can also use the free API key instead of signed requests
    # See https://developers.google.com/maps/documentation/geocoding/#api_key
    Geokit::Geocoders::GoogleGeocoder.api_key = ''

    # You can also set multiple API KEYS for different domains that may be directed to this same application.
    # The domain from which the current user is being directed will automatically be updated for Geokit via
    # the GeocoderControl class, which gets it's begin filter mixed into the ActionController.
    # You define these keys with a Hash as follows:
    #Geokit::Geocoders::google = { 'rubyonrails.org' => 'RUBY_ON_RAILS_API_KEY', 'ruby-docs.org' => 'RUBY_DOCS_API_KEY' }

    # This is your username and password for geocoder.us.
    # To use the free service, the value can be set to nil or false.  For
    # usage tied to an account, the value should be set to username:password.
    # See http://geocoder.us
    # and http://geocoder.us/user/signup
    Geokit::Geocoders::UsGeocoder.key = 'username:password'

    # This is your authorization key for geocoder.ca.
    # To use the free service, the value can be set to nil or false.  For
    # usage tied to an account, set the value to the key obtained from
    # Geocoder.ca.
    # See http://geocoder.ca
    # and http://geocoder.ca/?register=1
    Geokit::Geocoders::CaGeocoder.key = 'KEY'

    # This is your username key for geonames.
    # To use this service either free or premium, you must register a key.
    # See http://www.geonames.org
    Geokit::Geocoders::GeonamesGeocoder.key = 'KEY'

    # Most other geocoders need either no setup or a key
    Geokit::Geocoders::BingGeocoder.key = ''
    Geokit::Geocoders::MapQuestGeocoder.key = ''
    Geokit::Geocoders::YandexGeocoder.key = ''
    Geokit::Geocoders::MapboxGeocoder.key = 'ACCESS_TOKEN'
    Geokit::Geocoders::OpencageGeocoder.key = 'some_api_key'

    # Geonames has a free service and a premium service, each using a different URL
    # GeonamesGeocoder.premium = true will use http://ws.geonames.net (premium)
    # GeonamesGeocoder.premium = false will use http://api.geonames.org (free)
    Geokit::Geocoders::GeonamesGeocoder.premium = false

    # require "external_geocoder.rb"
    # Please see the section "writing your own geocoders" for more information.
    # Geokit::Geocoders::external_key = 'REPLACE_WITH_YOUR_API_KEY'

    # This is the order in which the geocoders are called in a failover scenario
    # If you only want to use a single geocoder, put a single symbol in the array.
    # Valid symbols are :google, :yahoo, :us, and :ca.
    # Be aware that there are Terms of Use restrictions on how you can use the
    # various geocoders.  Make sure you read up on relevant Terms of Use for each
    # geocoder you are going to use.
    Geokit::Geocoders::provider_order = [:google,:us]

    # The IP provider order. Valid symbols are :ip,:geo_plugin.
    # As before, make sure you read up on relevant Terms of Use for each.
    # Geokit::Geocoders::ip_provider_order = [:external,:geo_plugin,:ip]

	# Disable HTTPS globally.  This option can also be set on individual
	# geocoder classes.
    Geokit::Geocoders::secure = false

    # Control verification of the server certificate for geocoders using HTTPS
    Geokit::Geocoders::ssl_verify_mode = OpenSSL::SSL::VERIFY_(PEER/NONE)
    # Setting this to VERIFY_NONE may be needed on systems that don't have
    # a complete or up to date root certificate store. Only applies to
    # the Net::HTTP adapter.
```

### Google Geocoder Tricks

The Google Geocoder sports a number of useful tricks that elevate it a little bit above the rest of the currently supported geocoders. For starters, it returns a `suggested_bounds` property for all your geocoded results, so you can more easily decide where and how to center a map on the places you geocode. Here's a quick example:

```ruby
    irb> res = Geokit::Geocoders::GoogleGeocoder.geocode('140 Market St, San Francisco, CA')
    irb> pp res.suggested_bounds
    #<Geokit::Bounds:0x53b36c
     @ne=#<Geokit::LatLng:0x53b204 @lat=37.7968528, @lng=-122.3926933>,
     @sw=#<Geokit::LatLng:0x53b2b8 @lat=37.7905576, @lng=-122.3989885>>

In addition, you can use viewport or country code biasing to make sure the geocoders prefers results within a specific area. Say we wanted to geocode the city of Toledo in Spain. A normal geocoding query would look like this:

    irb> res = Geokit::Geocoders::GoogleGeocoder.geocode('Toledo')
    irb> res.full_address
    => "Toledo, OH, USA"
```

Not exactly what we were looking for. We know that Toledo is in Spain, so we can tell the Google Geocoder to prefer results from Spain first, and then wander the Toledos of the world. To do that, we have to pass Italy's ccTLD (country code top-level domain) to the `:bias` option of the `geocode` method. You can find a comprehensive list of all ccTLDs here: http://en.wikipedia.org/wiki/CcTLD.

```ruby
    irb> res = Geokit::Geocoders::GoogleGeocoder.geocode('Toledo', :bias => 'es')
    irb> res.full_address
    => "Toledo, Toledo, Spain"
```

Alternatively, we can specify the geocoding bias as a bounding box object. Say we wanted to geocode the Winnetka district in Los Angeles.

```ruby
    irb> res = Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka')
    irb> res.full_address
    => "Winnetka, IL, USA"
```

Not it. What we can do is tell the geocoder to return results only from in and around LA.

```ruby
    irb> la_bounds = Geokit::Geocoders::GoogleGeocoder.geocode('Los Angeles').suggested_bounds
    irb> res = Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka', :bias => la_bounds)
    irb> res.full_address
    => "Winnetka, California, USA"
```


### The Multigeocoder
Multi Geocoder - provides failover for the physical location geocoders, and also IP address geocoders. Its configured by setting Geokit::Geocoders::provider_order, and Geokit::Geocoders::ip_provider_order. You should call the Multi-Geocoder with its :geocode method, supplying one address parameter which is either a real street address, or an ip address. For example:

```ruby
    Geokit::Geocoders::MultiGeocoder.geocode("900 Sycamore Drive")

    Geokit::Geocoders::MultiGeocoder.geocode("12.12.12.12")
```

## MULTIPLE RESULTS
Some geocoding services will return multple results if the there isn't one clear result.
Geoloc can capture multiple results through its "all" method. Currently only the Google geocoder
supports multiple results:

```ruby
    irb> geo=Geokit::Geocoders::GoogleGeocoder.geocode("900 Sycamore Drive")
    irb> geo.full_address
    => "900 Sycamore Dr, Arkadelphia, AR 71923, USA"
    irb> geo.all.size
    irb> geo.all.each { |e| puts e.full_address }
    900 Sycamore Dr, Arkadelphia, AR 71923, USA
    900 Sycamore Dr, Burkburnett, TX 76354, USA
    900 Sycamore Dr, TN 38361, USA
    ....
```

geo.all is just an array of additional Geolocs, so do what you want with it. If you call .all on a
geoloc that doesn't have any additional results, you will get  an array of one.


## NOTES ON WHAT'S WHERE

mappable.rb contains the Mappable module, which provides basic
distance calculation methods, i.e., calculating the distance
between two points.

LatLng is a simple container for latitude and longitude, but
it's made more powerful by mixing in the above-mentioned Mappable
module -- therefore, you can calculate easily the distance between two
LatLng ojbects with `distance = first.distance_to(other)`

GeoLoc represents an address or location which
has been geocoded. You can get the city, zipcode, street address, etc.
from a GeoLoc object. GeoLoc extends LatLng, so you also get lat/lng
AND the Mappable module goodness for free.

geocoders.rb contains all the geocoder implemenations. All the gercoders
inherit from a common base (class Geocoder) and implement the private method
do_geocode.

## WRITING YOUR OWN GEOCODERS

If you would like to write your own geocoders, you can do so by requiring 'geokit' or 'geokit/geocoders.rb' in a new file and subclassing the base class (which is class "Geocoder").
You must then also require such external file back in your main geokit configuration.

```ruby
  require "geokit"

  module Geokit
    module Geocoders

      # and use :my to specify this geocoder in your list of geocoders.
      class MyGeocoder < Geocoder

        # Use via: Geokit::Geocoders::MyGeocoder.key = 'MY KEY'
        config :key

        private

        def self.do_geocode(address, options = {})
          # Main geocoding method
        end

        def self.parse_json(json)
          # Helper method to parse http response. See geokit/geocoders.rb.
        end
      end

    end
  end
```
