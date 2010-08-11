$:.unshift File.expand_path('../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'

begin
  require 'spec/rake/spectask'
rescue LoadError
  task :spec do
    $stderr.puts '`gem install rspec` to run specs'
  end
else
  Spec::Rake::SpecTask.new do |t|
    t.libs << 'lib'
    t.libs << 'spec'
    t.warning = false
  end
end