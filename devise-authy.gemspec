# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "devise-authy/version"

Gem::Specification.new do |spec|
  spec.name          = "devise-authy"
  spec.version       = DeviseAuthy::VERSION
  spec.authors       = ["Authy Inc."]
  spec.email         = ["support@authy.com"]

  spec.summary       = %q{Authy plugin for Devise.}
  spec.description   = %q{Authy plugin to add two factor authentication to Devise.}
  spec.homepage      = "https://github.com/authy/authy-devise"
  spec.license       = "MIT"

  spec.metadata      = {
    "bug_tracker_uri"   => "https://github.com/authy/authy-devise/issues",
    "change_log_uri"    => "https://github.com/authy/authy-devise/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/authy/authy-devise",
    "homepage_uri"      => "https://github.com/authy/authy-devise",
    "source_code_uri"   => "https://github.com/authy/authy-devise"
  }

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "devise", ">= 3.0.0"
  spec.add_dependency "authy", ">= 2.7.2"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard", "~> 0.9.11"
  spec.add_development_dependency "rdoc", "~> 4.3.0"
  spec.add_development_dependency "simplecov", "~> 0.16.1"
end
