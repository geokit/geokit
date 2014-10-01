## 1.9.0

* Drop Ruby 1.8 support
* Make meter centric
* Add meters as a unit
* Use state_name/state_code instead of state

## 1.8.5

* HTTPS on Google, Bing, Yahoo and MapQuest
* Added Geocod.io Geocoder
* Can use Google Key on free geocoder
* Fix bug in RIPE geocoder where no locations returned
* provider_order option for MultiGeocoder
* dms return methods (degree, minute, second)

## 1.8.4

* Fix math error in ruby 1.8
* Extract HTTP processing to allow different HTTP clients for caching, etc.

## 1.8.3

* Fix MultiGeocoder with geocoders that only have one argument

## 1.8.2

* Fix due to name clash with dependency definitions in geokit 1.8.1
* Standaride GeoLoc provider string

## 1.8.1

* Change way keys/dependencies defined

## 1.8.0

* Added Bing Geocoder
* Added freegeoip.net Geocoder
* Added MapQuest Geocoder
* Remove Google (v2) Geocoder and rename Google3 (v3) to Google
* Added tests for various gateways
* Greatly standarize, simplify and improve code
* Reorganise files
* MaxMind bug fixes

## 1.7.1

* Remove geoip require from MaxMind to avoid new dependency issues

## 1.7.0

* Added Yahoo Boss, Yandex, RIPE and MaxMind Support
* Integration tests for google/yahoo boss
* Other minor fixes/improvements

## 1.6.6

* Minor fixes/improvements

## 1.6.5 / 2012-01-23

* first release by @imajes, thanks @andre for all the hard work!
* normalized whitespace
* added support for subpremise on google3 encoder
* fixed yahoo's support by switching to placefinder
* switched to multi json for agnostic json support
* removed hoe and replaced with bundler's gem harness

## 1.6.0 / 2011-05-27

* added Google geocoder3 support (thanks @projectdx)
* added FCC encoder support (thanks @paulschreiber)
* various minor fixes.

## 1.5.0 / 2009-09-21

* fixed jruby compatibility (thanks manalang)
* added country name to Google reverse geocoder (thanks joahking)
* added  DependentLocalityName as district, and SubAdministrativeAreaName as province (google geocoder only)
* Google geocoder throws an error if you exceed geocoding rates (thanks drogus)

## 1.4.1 / 2009-06-15

* Fixed Ruby 1.9.1 compat and load order (thanks Niels Ganser)

## 1.4.0 / 2009-05-27

* Added country code/viewport biasing to GoogleGeocoder. Added Bounds#to_span method
* Added suggested_bounds (Geokit::Bounds) property to GeoLoc. (Google geocoder only)
* Added LatLng#reverse_geocode convenience method (thanks Tisho Georgiev for all three)

## 1.3.2 / 2009-05-27

* Fixed blank address geocoding bug

## 1.3.1 / 2009-05-21

* Support for External geocoders file (thanks dreamcat4)
* Support multiple ip geocoders, including new setting for ip_provider_order (thanks dreamcat4)

## 1.3.0 / 2009-04-11

* Added capability to define multiple API keys for different domains that may be pointing to the same application (thanks Glenn Powell)
* Added numeric accuracy accessor for Yahoo and Google geocoders (thanks Andrew Fecheyr Lippens)
* Implement #hash and #eql? on LatLng to allow for using it as a hash key (thanks Luke Melia and Ross Kaffenberger)

## 1.2.6 / 2009-03-19

* misc minor fixes

## 1.2.5 / 2009-02-25

* fixed GeoLoc.to_yaml
* fixed minor google geocoding bug
* now periodically publishing the Geokit gem to Rubyforge. Still maintaining development and managing contributions at Github

## 1.2.4 / 2009-02-25

* Improved Google geocoder in the Gem: Support for multiple geocoding results from the Google geocoder. (thanks github/pic)

## 1.2.3 / 2009-02-01

* Adding GeoPluginGeocoder for IP geocoding (thanks github/xjunior)
* Ruby 1.9.1 compatibility and Unicode fixes (thanks github/Nielsomat)
* various bug fixes

## 1.2.1 / 2009-01-05

* minor bug fixes
* reverse geocoding added (Google only): res=Geokit::Geocoders::GoogleGeocoder.reverse_geocode "37.791821,-122.394679"
* nautical miles added (in addition to miles and KM)

## 1.2.0 / 2008-12-01

* Improved Geocoder.us support -- respects authentication, and can geocode city names or zipcodes alone
* cross-meridian finds work correctly with bounds conditions
* fixed a problem with columns with "distance" in their name
* added Geonames geocoder
* the gem and plugin are now hosted at Github.

## 1.1.1 / 2008-01-20

* fixes for distance calculation (in-memory and database) when distances are either very small or 0. 
* NOTE: older versions of MySQL/Postgres may not work. See readme for more info.

## 1.1.0 / 2007-12-07

* Geokit is now Rails 2.0 / Edge friendly. 

## 1.0.0 / 2007-07-22

* see http://earthcode.com/blog/2007/07/new_geokit_release.html
* auto geocoding: an option to automatically geocode a model's address field on create
* in-memory sort-by-distance for arrays of location objects
* bounding box queries: `Location.find :all, :bounds=>[sw,ne]`
* improved performance by automatically adding a bounding box condition to radial queries
* new Bounds class for in-memory bounds-related operations
* ability to calculate heading and midpoint between two points
* ability to calculate endpoint given a point, heading, and distance

