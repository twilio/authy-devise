# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"

require "bundler"

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

Bundler.require :default, :development

require 'devise'
require './lib/devise-authy'
Combustion.initialize!(:all)

require "rspec/rails"
require "webmock/rspec"
require "generator_spec"
require "database_cleaner"
require "./spec/factories.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if config.respond_to?(:use_transactional_tests)
    config.use_transactional_tests = false
  else
    config.use_transactional_fixtures = false
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include FactoryBot::Syntax::Methods
end