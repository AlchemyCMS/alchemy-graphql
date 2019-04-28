# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "alchemy/graphql/version"

Gem::Specification.new do |spec|
  spec.name        = "alchemy-graphql"
  spec.version     = Alchemy::GraphQL::VERSION
  spec.authors     = ["Thomas von Deyen"]
  spec.email       = ["thomas@vondeyen.com"]
  spec.homepage    = "https://alchemy-cms.com"
  spec.summary     = "Alchemy::GraphQL"
  spec.description = "Description of Alchemy::GraphQL"
  spec.license     = "BSD-3-Clause"
  spec.files = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "alchemy_cms", ">= 4.2.0.rc1", "< 5"
  spec.add_dependency "graphql", "~> 1.9"
end
