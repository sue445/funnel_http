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

namespace :rbs do
  desc "`rbs collection install` and `git commit`"
  task :install do
    sh "rbs collection install"
    sh "git add rbs_collection.lock.yaml"
    sh "git commit -m 'rbs collection install' || true"
  end
end

desc "Check rbs"
task :rbs do
  sh "rbs validate"
  sh "steep check"
end

task default: %i[clobber compile spec]
