# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/geokit.rb'

Hoe.new('Geokit', Geokit::VERSION) do |p|
  # p.rubyforge_name = 'Geokitx' # if different than lowercase project name
  p.developer('Andre Lewis and Bill Eisenhauer', 'andre@earthcode.com / bill_eisenhauer@yahoo.com')
end

task :generate_gemspec do
  system "rake debug_gem | grep -v \"(in \" > `basename \\`pwd\\``.gemspec"
end

task :update_manifest do
  system "touch Manifest.txt; rake check_manifest | grep -v \"(in \" | patch"
end

# vim: syntax=Ruby
