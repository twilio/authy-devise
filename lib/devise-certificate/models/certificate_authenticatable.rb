require 'devise-certificate/hooks/certificate_authenticatable'
module Devise
  module Models
    module CertificateAuthenticatable
      extend ActiveSupport::Concern

      def with_certificate_authentication?(request)
        if self.certificate_id.present? && self.certificate_enabled
          return true
        end

        return false
      end

      module ClassMethods
        def find_by_certificate_id(certificate_id)
          find(:first, :conditions => {:certificate_id => certificate_id})
        end

        Devise::Models.config(self, :certificate_remember_device)
      end
    end
  end
end

