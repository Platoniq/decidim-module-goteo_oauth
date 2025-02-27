# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/goteo_oauth/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-goteo_oauth"
  spec.version = Decidim::GoteoOauth::VERSION
  spec.authors = ["Alexandru-Emil Lupu"]
  spec.email = ["pfa@alecslupu.ro"]

  spec.summary = "A module for Decidim that enables Oauth login with Goteo."
  spec.description = "A module for Decidim that enables Oauth login with Goteo."
  spec.license = "AGPL-3.0"
  spec.homepage = "https://github.com/Platoniq/decidim-module-goteo_oauth"
  spec.required_ruby_version = ">= 3.1"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-core", Decidim::GoteoOauth::COMPAT_DECIDIM_VERSION

  spec.add_development_dependency "decidim-dev", Decidim::GoteoOauth::COMPAT_DECIDIM_VERSION
  spec.metadata["rubygems_mfa_required"] = "true"
end
