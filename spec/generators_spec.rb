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
    expect(@output.include?('devise_authy:install')).to be_truthy
    expect(@output.include?('active_record:devise_authy')).to be_truthy
  end

  it "rails g devise_authy:install" do
    @output = rails_command("g", "devise_authy:install", "-s")
    expect(@output.include?('config/initializers/devise.rb')).to be_truthy
    expect(@output.include?('config/locales/devise.authy.en.yml')).to be_truthy
    expect(@output.include?('app/views/devise/devise_authy/enable_authy.html.erb')).to be_truthy
    expect(@output.include?('app/views/devise/devise_authy/verify_authy.html.erb')).to be_truthy
    expect(@output.include?('app/views/devise/devise_authy/verify_authy_installation.html.erb')).to be_truthy
    expect(@output.include?('app/assets/stylesheets/devise_authy.css')).to be_truthy
    expect(@output.include?('app/assets/javascripts/devise_authy.js')).to be_truthy
  end
end
