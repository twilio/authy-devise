require 'spec_helper'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'rails/generators'
require 'generators/devise_certificate/devise_certificate_generator'

describe "generators for devise_certificate" do
  RAILS_APP_PATH = File.expand_path("../rails-app", __FILE__)

  def rails_command(*args)
    `cd #{RAILS_APP_PATH} && BUNDLE_GEMFILE=#{RAILS_APP_PATH}/Gemfile bundle exec rails #{args.join(" ")}`
  end

  it "rails g should include the generators" do
    @output = rails_command("g")
    @output.include?('devise_certificate:install').should be_true
    @output.include?('active_record:devise_certificate').should be_true
  end

  it "rails g devise_certificate:install" do
    @output = rails_command("g", "devise_certificate:install", "-s")
    @output.include?('config/initializers/devise.rb').should be_true
    @output.include?('config/locales/devise.certificate.en.yml').should be_true
    @output.include?('app/views/devise/devise_certificate/enable_certificate.html.erb').should be_true
    @output.include?('app/views/devise/devise_certificate/verify_certificate.html.erb').should be_true
    @output.include?('app/views/devise/devise_certificate/verify_certificate_installation.html.erb').should be_true
    @output.include?('app/assets/stylesheets/devise_certificate.css').should be_true
    @output.include?('app/assets/javascripts/devise_certificate.js').should be_true
  end
end

