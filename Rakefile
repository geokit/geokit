require "bundler/gem_tasks"
require 'rake/testtask'

task :default do
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc "Generate SimpleCov test coverage and open in your browser"
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].invoke
end

desc "Downloads GeoLiteCity.dat from maxmind.com"
task :download_geolitecity do
  total_size = nil
  url = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'
  progress_cb = lambda {|size| print("Downloaded #{size} of #{total_size} bytes\r") if total_size }
  length_cb = lambda {|content_length| total_size = content_length }
  require 'open-uri'
  File.open("/tmp/GeoLiteCity.dat.gz", "wb") do |f|
    open(url, 'rb', :progress_proc => progress_cb, :content_length_proc => length_cb ) do |downloaded_file|
      f.write(downloaded_file.read)
    end
  end
  puts "\nDone."
end