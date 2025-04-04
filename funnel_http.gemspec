# frozen_string_literal: true

require_relative "lib/funnel_http/version"

Gem::Specification.new do |spec|
  spec.name = "funnel_http"
  spec.version = FunnelHttp::VERSION
  spec.authors = ["sue445"]
  spec.email = ["sue445@sue445.net"]

  spec.summary = "Perform HTTP requests in parallel with goroutine"
  spec.description = "Perform HTTP requests in parallel with goroutine"
  spec.homepage = "https://github.com/sue445/funnel_http"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://sue445.github.io/funnel_http/"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ benchmark/ .git .github appveyor Gemfile]) ||
        f.end_with?(*%w[_test.go])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/funnel_http/extconf.rb"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "go_gem", "~> 0.6"

  spec.add_development_dependency "puma"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rackup"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "steep"
  spec.add_development_dependency "yard"

  # for benchmarker
  spec.add_development_dependency "benchmark-ips"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
