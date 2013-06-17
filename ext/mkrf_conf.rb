require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb'
begin
  Gem::Command.build_args = ARGV
  rescue NoMethodError
end
inst = Gem::DependencyInstaller.new
begin
  if RUBY_VERSION < "1.9"
    inst.install "iconv"
  end
rescue
  exit(1)
end
