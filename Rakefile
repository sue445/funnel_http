# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rake/extensiontask"

task build: :compile

GEMSPEC = Gem::Specification.load("funnel_http.gemspec")

Rake::ExtensionTask.new("funnel_http", GEMSPEC) do |ext|
  ext.lib_dir = "lib/funnel_http"
end

task default: %i[clobber compile spec]
