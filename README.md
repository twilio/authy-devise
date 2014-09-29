# Authy Devise

This is a [Devise](https://github.com/plataformatec/devise) extension to add Two-Factor Authentication with Authy to your rails application.


## Pre-requisites

Get an Authy API Key: [https://www.authy.com/signup](https://www.authy.com/signup)

## Demo

See [https://github.com/authy/authy-devise/tree/master/authy-devise-demo](https://github.com/authy/authy-devise/tree/master/authy-devise-demo)

## Getting started

First create an initializer in `config/initializers/authy.rb`

```ruby
Authy.api_key = ENV['AUTHY_API_KEY'] || 'your_authy_api_key'
Authy.api_uri = 'https://api.authy.com/'
```

You can get the `AUTHY_API_KEY` at [https://www.authy.com/signup](https://www.authy.com/signup)

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

Configure your Devise user model:

    rails g devise_authy [MODEL_NAME]

or add the following line to your `User` model

```ruby
devise :authy_authenticatable, :database_authenticatable
```

Change the default routes to point to something sane like:

```ruby
devise_for :users, :path_names => {
	:verify_authy => "/verify-token",
	:enable_authy => "/enable-two-factor",
	:verify_authy_installation => "/verify-installation"
}
```

Then run the migrations:

    rake db:migrate

Now whenever a user wants to enable two-factor authentication they can go
to:

    http://your-app/users/enable-two-factor

And when the user log's in he will be redirected to:

    http://your-app/users/verify-token


## Custom Views

If you want to customise your views, you can modify the files that are located at:

    app/views/devise/devise_authy/enable_authy.html.erb
    app/views/devise/devise_authy/verify_authy.html.erb
    app/views/devise/devise_authy/verify_authy_installation.html.erb


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

    def invalid_resource_path
      my_own_path
    end
end
```


## I18n

The install generator also copy a `Devise Authy` i18n file which you can find at:

    config/locales/devise.authy.en.yml

## Copyright

Copyright (c) 2014 Authy Inc. See LICENSE.txt for
further details.
