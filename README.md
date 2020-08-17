# Authy Devise [![Build Status](https://travis-ci.org/twilio/authy-devise.svg?branch=master)](https://travis-ci.org/twilio/authy-devise)

This is a [Devise](https://github.com/plataformatec/devise) extension to add [Two-Factor Authentication with Authy](https://www.twilio.com/docs/authy) to your Rails application.

* [Pre-requisites](#pre-requisites)
* [Demo](#demo)
* [Getting started](#getting-started)
  * [Configuring Models](#configuring-models)
    * [With the generator](#with-the-generator)
    * [Manually](#manually)
    * [Final steps](#final-steps)
* [Custom Views](#custom-views)
  * [Request a phone call](#request-a-phone-call)
* [Custom Redirect Paths (eg. using modules)](#custom-redirect-paths-eg-using-modules)
* [I18n](#i18n)
* [Session variables](#session-variables)
* [OneTouch support](#onetouch-support)
* [Generic authenticator token support](#generic-authenticator-token-support)
* [Rails 5 CSRF protection](#rails-5-csrf-protection)
* [Running Tests](#running-tests)
* [Copyright](#copyright)

## Pre-requisites

To use the Authy API you will need a Twilio Account, [sign up for a free Twilio account here](https://www.twilio.com/try-twilio).

Create an [Authy Application in the Twilio console](https://www.twilio.com/console/authy/applications) and take note of the API key.

## Demo

See [this repo for a full demo of using `authy-devise`](https://github.com/twilio/authy-devise-demo).

## Getting started

First get your Authy API key from [the Twilio console](https://www.twilio.com/console/authy/applications). We recommend you store your API key as an environment variable.

```bash
$ export AUTHY_API_KEY=YOUR_AUTHY_API_KEY
```

Next add the gem to your Gemfile:

```ruby
gem 'devise'
gem 'devise-authy'
```

And then run `bundle install`

Add `Devise Authy` to your App:

    rails g devise_authy:install

    --haml: Generate the views in Haml
    --sass: Generate the stylesheets in Sass

### Configuring Models

You can add devise_authy to your user model in two ways.

#### With the generator

Run the following command:

```bash
rails g devise_authy [MODEL_NAME]
```

To support account locking (recommended), you must add `:authy_lockable` to the `devise :authy_authenticatable, ...` configuration in your model as this is not yet supported by the generator.

#### Manually

Add `:authy_authenticatable` and `:authy_lockable` to the `devise` options in your Devise user model:

```ruby
devise :authy_authenticatable, :authy_lockable, :database_authenticatable, :lockable
```

(Note, `:authy_lockable` is optional but recommended. It should be used with Devise's own `:lockable` module).

Also add a new migration. For example, if you are adding to the `User` model, use this migration:

```ruby
class DeviseAuthyAddToUsers < ActiveRecord::Migration[6.0]
  def self.up
    change_table :users do |t|
      t.string    :authy_id
      t.datetime  :last_sign_in_with_authy
      t.boolean   :authy_enabled, :default => false
    end

    add_index :users, :authy_id
  end

  def self.down
    change_table :users do |t|
      t.remove :authy_id, :last_sign_in_with_authy, :authy_enabled
    end
  end
end
```

#### Final steps

For either method above, run the migrations:

```bash
rake db:migrate
```

**[Optional]** Update the default routes to point to something like:

```ruby
devise_for :users, :path_names => {
	:verify_authy => "/verify-token",
	:enable_authy => "/enable-two-factor",
	:verify_authy_installation => "/verify-installation",
	:authy_onetouch_status => "/onetouch-status"
}
```

Now whenever a user wants to enable two-factor authentication they can go to:

    http://your-app/users/enable-two-factor

And when the user logs in they will be redirected to:

    http://your-app/users/verify-token

## Custom Views

If you want to customise your views, you can modify the files that are located at:

    app/views/devise/devise_authy/enable_authy.html.erb
    app/views/devise/devise_authy/verify_authy.html.erb
    app/views/devise/devise_authy/verify_authy_installation.html.erb

### Request a phone call

The default views come with a button to force a request for an SMS message. You can also add a button that will request a phone call instead. Simply add the helper method to your view:

    <%= authy_request_phone_call_link %>

## Custom Redirect Paths (eg. using modules)

If you want to customise the redirects you can override them within your own controller like this:

```ruby
class MyCustomModule::DeviseAuthyController < Devise::DeviseAuthyController

  protected
    def after_authy_enabled_path_for(resource)
      my_own_path
    end

    def after_authy_verified_path_for(resource)
      my_own_path
    end

    def after_authy_disabled_path_for(resource)
      my_own_path
    end

    def invalid_resource_path
      my_own_path
    end
end
```

And tell the router to use this controller

```ruby
devise_for :users, controllers: {devise_authy: 'my_custom_module/devise_authy'}
```

## I18n

The install generator also copies a `Devise Authy` i18n file which you can find at:

    config/locales/devise.authy.en.yml

## Session variables

If you want to know if the user is signed in using Two-Factor authentication,
you can use the following session variable:

```ruby
session["#{resource_name}_authy_token_checked"]

# Eg.
session["user_authy_token_checked"]
```

## OneTouch support

To enable [Authy push authentication](https://www.twilio.com/authy/features/push), you need to modify the Devise config file `config/initializers/devise.rb` and add configuration:

```
config.authy_enable_onetouch = true
```

## Generic authenticator token support

Authy supports other authenticator apps by providing a QR code that your users can scan.

> **To use this feature, you need to enable it in your [Twilio Console](https://www.twilio.com/console/authy/applications)**

Once you have enabled generic authenticator tokens, you can enable this in devise-authy by modifying the Devise config file `config/initializers/devise.rb` and adding the configuration:

```
config.authy_enable_qr_code = true
```

This will display a QR code on the verification screen (you still need to take a user's phone number and country code). If you have implemented your own views, the QR code URL is available on the verification page as `@authy_qr_code`.

## Rails 5 CSRF protection

In Rails 5 `protect_from_forgery` is no longer prepended to the `before_action` chain. If you call `authenticate_user` before `protect_from_forgery` your request will result in a "Can't verify CSRF token authenticity" error.

To remedy this, add `prepend: true` to your `protect_from_forgery` call, like in this example from the [Authy Devise demo app](https://github.com/twilio/authy-devise-demo):

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
end
```

## Running Tests

To prepare the tests run the following commands:

```bash
$ cd spec/rails-app
$ bundle install
$ RAILS_ENV=test bundle exec rake db:migrate
```

Now on the project root run the following commands:

```bash
$ bundle exec rspec spec/
```

## Copyright

Copyright (c) 2012-2020 Authy Inc. See LICENSE.txt for further details.
