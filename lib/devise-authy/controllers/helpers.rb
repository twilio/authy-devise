module DeviseAuthy
  module Controllers
    module Helpers
      extend ActiveSupport::Concern

      included do
        before_action :check_request_and_redirect_to_verify_token, :if => :is_signing_in?
      end

      private
      def remember_device
        cookies.signed[:remember_device] = {
          :value => Time.now.to_i,
          :secure => !(Rails.env.test? || Rails.env.development?),
          :expires => resource_class.authy_remember_device.from_now
        }
      end

      def require_token?
        if cookies.signed[:remember_device].present? &&
          (Time.now.to_i - cookies.signed[:remember_device].to_i) < \
          resource_class.authy_remember_device.to_i
          return false
        end

        return true
      end

      def is_devise_sessions_controller?
        self.class == Devise::SessionsController || self.class.ancestors.include?(Devise::SessionsController)
      end

      def is_signing_in?
        if devise_controller? && signed_in?(resource_name) &&
          is_devise_sessions_controller? &&
          self.action_name == "create"
          return true
        end

        return false
      end

      def check_request_and_redirect_to_verify_token
        if signed_in?(resource_name) &&
           warden.session(resource_name)[:with_authy_authentication] &&
           require_token?
          # login with 2fa
          id = warden.session(resource_name)[:id]

          remember_me = (params.fetch(resource_name, {})[:remember_me].to_s == "1")
          return_to = session["#{resource_name}_return_to"]
          warden.logout
          warden.reset_session! # make sure the session resetted

          session["#{resource_name}_id"] = id
          # this is safe to put in the session because the cookie is signed
          session["#{resource_name}_password_checked"] = true
          session["#{resource_name}_remember_me"] = remember_me
          session["#{resource_name}_return_to"] = return_to if return_to

          redirect_to verify_authy_path_for(resource_name)
          return
        end
      end

      def verify_authy_path_for(resource_or_scope = nil)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send(:"#{scope}_verify_authy_path")
      end
    end
  end
end
