require 'spec_helper'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'rails/generators'
require 'generators/devise_authy/devise_authy_generator'

describe "generators for devise_authy" do
  RAILS_APP_PATH = File.expand_path("../rails-app", __FILE__)

  def rails_command(*args)
    `cd #{RAILS_APP_PATH} && BUNDLE_GEMFILE=#{RAILS_APP_PATH}/Gemfile bundle exec rails #{args.join(" ")}`
  end

  it "rails g should include the generators" do
    @output = rails_command("g")
    @output.include?('devise_authy:install').should be_true
    @output.include?('active_record:devise_authy').should be_true
  end

  it "rails g devise_authy:install" do
    @output = rails_command("g", "devise_authy:install", "-s")
    @output.include?('config/initializers/devise.rb').should be_true
    @output.include?('authy.rb').should be_true
    @output.include?('config/locales/devise.authy.en.yml').should be_true
    @output.include?('app/views/devise/devise_authy/enable_authy.html.erb').should be_true
    @output.include?('app/views/devise/devise_authy/verify_authy.html.erb').should be_true
    @output.include?('app/views/devise/devise_authy/verify_authy_installation.html.erb').should be_true
    @output.include?('app/assets/stylesheets/devise_authy.css').should be_true
    @output.include?('app/assets/javascripts/devise_authy.js').should be_true
  end
end
