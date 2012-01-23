# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'geokit/version'

Gem::Specification.new do |s|
  s.name        = "geokit"
  s.version     = Geokit::VERSION
  s.authors     = ["James Cox, Andre Lewis & Bill Eisenhauer"]
  s.email       = ["james+geokit@imaj.es"]
  s.homepage    = "https://github.com/imajes/geokit-gem"

  s.summary     = %q{Geokit: encoding and distance calculation gem}
  s.description = %q{Geokit provides geocoding and distance calculation in an easy-to-use API}

  s.rubyforge_project = "geokit"

  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.markdown"]
  s.extra_rdoc_files = ["README.markdown"]

  s.files = ["README.markdown", "Rakefile", "lib/geokit/geocoders.rb", "lib/geokit.rb",
    "lib/geokit/mappable.rb", "test/test_base_geocoder.rb", "test/test_bounds.rb",
    "test/test_ca_geocoder.rb", "test/test_geoloc.rb", "test/test_google_geocoder3.rb",
    "test/test_google_geocoder.rb", "test/test_latlng.rb", "test/test_multi_geocoder.rb",
    "test/test_us_geocoder.rb", "test/test_yahoo_geocoder.rb"
  ]

  s.test_files = [
    "test/test_base_geocoder.rb", "test/test_bounds.rb", "test/test_ca_geocoder.rb",
    "test/test_geoloc.rb", "test/test_geoplugin_geocoder.rb", "test/test_google_geocoder3.rb",
    "test/test_google_geocoder.rb", "test/test_google_reverse_geocoder.rb", "test/test_inflector.rb",
    "test/test_ipgeocoder.rb", "test/test_latlng.rb", "test/test_multi_geocoder.rb",
    "test/test_multi_ip_geocoder.rb", "test/test_us_geocoder.rb", "test/test_yahoo_geocoder.rb"
  ]

  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency 'multi_json'
  s.add_development_dependency 'rake'
end

