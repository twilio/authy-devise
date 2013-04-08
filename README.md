# Authy Devise 

This is a [https://github.com/plataformatec/devise](devise) extension to add Two-Factor Authentication with Authy to your App. 

## Pre-requisites

Get a Authy API Key: [https://www.authy.com/signup](https://www.authy.com/signup)

## Getting started

First create an initializer, in config/initializer/authy.rb

    require 'authy'

    Authy.api_key = ENV['AUTHY_API_KEY'] || 'your_authy_api_key'

You can get the `AUTHY_API_KEY` at https://www.authy.com/signup 

Next add the gem to your Gemfile:

    gem 'devise'
    gem 'devise_authy', '0.0.1'

Run `bundle install`

Add Devise Authy to your App:

    rails g devise_authy:install

    --haml: Generate the views in Haml
    --sass: Generate the stylesheets in Sass

Configuring Models:

Configure your Devise user model, run:

    rails g devise_authy [MODEL_NAME]

or add this line to your  User model

    :authy_authenticatable

Example

    devise :authy_authenticatable, :database_authenticatable


Finally run the migrations:

    rake db:migrate

## Configuration Options

The install generator adds some options to the end of your Devise config file `config/initializers/devise.rb`

    config.authy_expires_at - How long should the user have to enter their Authy token. By default is 1 month.

## CND

Authy javascripts and css file of forms authy-form-helpers[https://github.com/authy/authy-form-helpers]

Add this in your HTML 
    
    <head>

    <link href="https://www.authy.com/form.authy.min.css" media="screen" rel="stylesheet" type="text/css">
    <script src="https://www.authy.com/form.authy.min.js" type="text/javascript"></script>


## Custom Views

If you want to customise your views, you can modify the files that are located at:

    app/views/devise/devise_authy/register.html.erb
    app/views/devise/devise_authy/show.html.erb

## I18n

The install generator also copy a Devise Authy i18n file. This can be modified and is  located at:

    config/locales/devise.authy.en.yml

## Contributing to devise_google_authenticator

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Johanna Mantilla Duque. See LICENSE.txt for
further details.
