source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"

# Authentication & security
gem "bcrypt", "~> 3.1.7"
gem "jwt"
gem "rack-attack"
gem "omniauth"
gem "omniauth-rails_csrf_protection"
gem "omniauth-google-oauth2"
gem "omniauth-github"
gem "rotp", "~> 6.3"
gem "rqrcode", "~> 3.2"

# Authorization
gem "pundit"

# API
gem "graphql"
gem "rack-cors"
gem "pagy"
gem "jsonapi-serializer"

# Multi-tenancy helpers
gem "acts_as_tenant"

# Soft delete
gem "discard"

# Excel / CSV / PDF
gem "csv"
gem "caxlsx"
gem "caxlsx_rails"
gem "prawn"
gem "prawn-table"

# Country / phone helpers
gem "countries"

# Solid Trifecta (preferred over Sidekiq/Redis for MVP)
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 2.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "graphiql-rails"
  gem "letter_opener"
end

group :test do
  gem "shoulda-matchers"
  gem "capybara"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "pundit-matchers"
end

gem "ruby-saml", "~> 1.18"
