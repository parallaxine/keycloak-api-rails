$:.push File.expand_path("../lib", __FILE__)

require "keycloak-api-rails/version"

Gem::Specification.new do |spec|
  spec.name        = "keycloak-api-rails"
  spec.version     = Keycloak::VERSION
  spec.authors     = ["Lorent Lempereur"]
  spec.email       = ["lorent.lempereur.dev@gmail.com"]
  spec.homepage    = "https://github.com/looorent/keycloak-api-rails"
  spec.summary     = "Rails middleware that validates Authorization token emitted by Keycloak"
  spec.description = "Rails middleware that validates Authorization token emitted by Keycloak"
  spec.license     = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_dependency "rails",       ">= 4.2"
  spec.add_dependency "json-jwt",    ">= 1.11.0"
  spec.add_dependency "anyway_config", ">= 2.1.0", "< 3"
  spec.add_dependency "dry-auto_inject"
  spec.add_dependency "dry-container"
  spec.add_dependency "dry-effects", ">= 0.0.1"
  spec.add_dependency "dry-initializer"
  spec.add_dependency "dry-matcher"
  spec.add_dependency "dry-monads", ">= 1.3.5", "< 2"
  spec.add_dependency "dry-struct"
  spec.add_dependency "dry-types"
  spec.add_dependency "dry-validation"

  spec.add_development_dependency "rspec",   "3.7.0"
  spec.add_development_dependency "timecop", "0.9.1"
  spec.add_development_dependency "byebug", "9.1.0"
  spec.add_development_dependency "pry"

  spec.required_ruby_version = ">= 2.7.0"
end
