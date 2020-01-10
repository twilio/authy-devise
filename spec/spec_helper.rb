# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"

require "bundler/setup"

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "webmock/rspec"
require "generator_spec"
require "devise-authy"
require "combustion"

Combustion.initialize!(:active_record, :action_controller)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end