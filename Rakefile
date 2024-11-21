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

require "go_gem/rake_task"

go_task = GoGem::RakeTask.new("funnel_http")

namespace :go do
  desc "Run golangci-lint"
  task :lint do
    go_task.within_target_dir do
      sh "which golangci-lint" do |ok, _|
        raise "golangci-lint isn't installed. See. https://golangci-lint.run/welcome/install/" unless ok
      end
      sh GoGem::RakeTask.build_env_vars, "golangci-lint run"
    end
  end

  desc "Run go mod tidy"
  task :mod_tidy do
    go_task.within_target_dir do
      sh "go mod tidy"
    end
  end
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

task default: %i[clobber compile spec go:test]
