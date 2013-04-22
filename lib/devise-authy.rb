require 'active_support/concern'
require 'active_support/core_ext/integer/time'
require 'devise-authy/version'
require 'devise'
require 'authy'

module Devise
  mattr_accessor :authy_remember_device
  @@authy_remember_device = 1.month
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
