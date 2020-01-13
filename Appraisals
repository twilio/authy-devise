appraise "rails-5-2" do
  gem "rails", "~> 5.2.0"
  gem "sqlite3", "~> 1.3.13"

  group :development, :test do
    gem 'factory_girl_rails', :require => false
    gem 'rspec-rails', :require => false
    gem 'database_cleaner', :require => false
  end
end

appraise "rails-6" do
  gem "rails", "~> 6.0.0"
  gem "sqlite3", "~> 1.4"

  group :development, :test do
    gem 'factory_girl_rails', :require => false
    gem 'rspec-rails', :require => false
    gem 'database_cleaner', :require => false
  end
end if RUBY_VERSION.to_f >= 2.5