source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in alchemy-graphql.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'alchemy_cms', github: 'AlchemyCMS/alchemy_cms'
gem 'sqlite3', '~> 1.3.6' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
gem 'mysql2', '~> 0.5.1' if ENV['DB'] == 'mysql'
gem 'pg', '~> 1.0' if ENV['DB'] == 'postgresql'
gem 'sassc-rails'
gem 'graphiql-rails', '~> 1.7'
gem 'pry-byebug'
gem 'listen'

if ENV['CI']
  group :test do
    gem 'rspec_junit_formatter', '~> 0.4'
  end
end
