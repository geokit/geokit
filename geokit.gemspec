# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{geokit}
  s.version = "1.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andre Lewis and Bill Eisenhauer"]
  s.date = %q{2009-08-02}
  s.description = %q{Geokit Gem}
  s.email = ["andre@earthcode.com / bill_eisenhauer@yahoo.com"]
  s.extra_rdoc_files = ["Manifest.txt", "README.markdown"]
  s.files = ["Manifest.txt", "README.markdown", "Rakefile", "lib/geokit/geocoders.rb", "lib/geokit.rb", "lib/geokit/mappable.rb", "test/test_base_geocoder.rb", "test/test_bounds.rb", "test/test_ca_geocoder.rb", "test/test_geoloc.rb", "test/test_google_geocoder.rb", "test/test_latlng.rb", "test/test_multi_geocoder.rb", "test/test_us_geocoder.rb", "test/test_yahoo_geocoder.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://geokit.rubyforge.org}
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{geokit}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{none}
  s.test_files = ["test/test_base_geocoder.rb", "test/test_bounds.rb", "test/test_ca_geocoder.rb", "test/test_geoloc.rb", 
  								"test/test_geoplugin_geocoder.rb", "test/test_google_geocoder.rb", "test/test_google_reverse_geocoder.rb", 
  								"test/test_inflector.rb", "test/test_ipgeocoder.rb", "test/test_latlng.rb", "test/test_multi_geocoder.rb", 
  								"test/test_multi_ip_geocoder.rb", "test/test_us_geocoder.rb", "test/test_yahoo_geocoder.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end


