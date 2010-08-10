require 'fileutils'
require 'rubygems'
require 'bundler/setup'
require 'spammeli'

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file
end

Spec::Runner.configure do |config|
  config.include Spec::Helpers
end