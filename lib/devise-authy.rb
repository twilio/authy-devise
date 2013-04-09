require 'active_support/concern'
require 'devise-authy/version'
require 'devise'
require 'authy'

module Devise
end

module DeviseAuthy
  module Controllers
    autoload :Helpers, 'devise-authy/controllers/helpers'
  end
  module Views
    autoload :Helpers, 'devise-authy/controllers/view_helpers'
  end
end

require 'devise-authy/routes'
require 'devise-authy/rails'
require 'devise-authy/models/authy_authenticatable'

Devise.add_module :authy_authenticatable, :model => 'devise-authy/models/authy_authenticatable', :controller => :devise_authy, :route => :authy
