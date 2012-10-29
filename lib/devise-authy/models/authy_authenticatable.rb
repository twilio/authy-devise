require 'devise-authy/hooks/authy_authenticatable'
module Devise
  module Models
    module AuthyAuthenticatable
      extend ActiveSupport::Concern

      def with_authy_authentication?(request)
        self.authy_id.present?
      end

      def send_request_sms

      end

      def verify_token(token)
        token = Authy::API.verify(:id => self.authy_id, :token => token)
        token.ok?
      end

      module ClassMethods
        def find_by_authy_id(authy_id)
          find(:first, :conditions => {:authy_id => authy_id})
        end
        ::Devise::Models.config(self, :api_key)
      end
    end
  end
end

