module DeviseAuthy
  module Controllers
    module Helpers
      extend ActiveSupport::Concern

      included do
        before_filter :check_request_and_redirect_to_verify_token
      end

      private

      def require_token?
        return true if cookies.signed[:remember_device].blank?
        return true if (Time.now.to_i - cookies.signed[:remember_device]) > \
          resource_class.authy_remember_device.to_i

        false
      end

      def check_request_and_redirect_to_verify_token
        if devise_controller? && !request.format.nil? && request.format.html?
          Devise.mappings.keys.flatten.any? do |scope|
            if signed_in?(scope) &&
              warden.session(scope)[:with_authy_authentication] && require_token?

              # login with 2fa
              id = warden.session(scope)[:id]
              warden.logout
              warden.reset_session! # make sure the session resetted
              session["#{scope}_id"] = id
              # this is safe to put in the session because the cookie is signed
              session["#{scope}_password_checked"] = true
              session["#{scope}_return_to"] = request.path if request.get?

              redirect_to verify_authy_path_for(scope)
              return
            end
          end
        end
      end

      def verify_authy_path_for(resource_or_scope = nil)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_verify_authy_path")
      end
    end
  end
end

