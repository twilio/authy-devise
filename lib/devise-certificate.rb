require 'active_support/concern'
require 'active_support/core_ext/integer/time'
require 'devise'
#require 'certificate'

module Devise
  mattr_accessor :certificate_remember_device
  @@certificate_remember_device = 1.month
end

module DeviseCertificate
  module Controllers
    autoload :Helpers, 'devise-certificate/controllers/helpers'
  end
  module Views
    autoload :Helpers, 'devise-certificate/controllers/view_helpers'
  end
end

require 'devise-certificate/routes'
require 'devise-certificate/rails'
require 'devise-certificate/models/certificate_authenticatable'

Devise.add_module :certificate_authenticatable, :model => 'devise-certificate/models/certificate_authenticatable', :controller => :devise_certificate, :route => :certificate
