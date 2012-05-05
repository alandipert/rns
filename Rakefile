require 'rubygems'
require 'bundler'
require "rspec/core/rake_task"
require 'rake'

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.ruby_opts = '-Ilib -Ispec -I.'
  t.rspec_opts = '--color'
end

task :default => :spec
