# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "geokit/version"

Gem::Specification.new do |s|
  s.name        = "geokit-premier"
  s.version     = Geokit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Forward (forked project from Andre Lewis and Bill Eisenhauer)"]
  s.email       = ["aforward@gmail.com"]
  s.homepage    = "https://github.com/aforward/geokit-premier-gem"
  s.summary     = %q{Enables google geocoding using a premier account}
  s.description = %q{Enhanced the google geocoder to take advantage of the premier account offering}

  s.add_dependency('json_pure')
  s.add_dependency('hoe')
  
  s.add_development_dependency('rspec', '>= 2.14.1')
  s.add_development_dependency('autotest')
  s.add_development_dependency('ZenTest')
  s.add_development_dependency('standalone_migrations')
  s.add_development_dependency('mysql')
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

# -*- encoding: utf-8 -*-
# Gem::Specification.new do |s|
#   # s.name = %q{geokit-premier}
#   s.version = "0.0.4"
# 
#   # s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
#   # s.date = %q{2009-08-02}
#   # s.extra_rdoc_files = ["Manifest.txt", "README.markdown"]
#   # s.files = ["Manifest.txt", "README.markdown", "Rakefile", "lib/geokit/geocoders.rb", "lib/geokit.rb", "lib/geokit/mappable.rb", "spec/geocoder_spec.rb", "spec/spec_helper.rb", "test/test_base_geocoder.rb", "test/test_bounds.rb", "test/test_ca_geocoder.rb", "test/test_geoloc.rb", "test/test_google_geocoder.rb", "test/test_latlng.rb", "test/test_multi_geocoder.rb", "test/test_us_geocoder.rb", "test/test_yahoo_geocoder.rb"]
#   # s.has_rdoc = true
#   # s.rdoc_options = ["--main", "README.markdown"]
#   # s.rubygems_version = %q{1.3.5}
#   # s.summary = %q{none}
#   # s.test_files = ["spec/geocoder_spec.rb", "test/test_base_geocoder.rb", "test/test_bounds.rb", "test/test_ca_geocoder.rb", "test/test_geoloc.rb", 
#   #                 "test/test_geoplugin_geocoder.rb", "test/test_google_geocoder.rb", "test/test_google_reverse_geocoder.rb", 
#   #                 "test/test_inflector.rb", "test/test_ipgeocoder.rb", "test/test_latlng.rb", "test/test_multi_geocoder.rb", 
#   #                 "test/test_multi_ip_geocoder.rb", "test/test_us_geocoder.rb", "test/test_yahoo_geocoder.rb"]
# 
#   if s.respond_to? :specification_version then
#     current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
#     s.specification_version = 2
#   end
# end


