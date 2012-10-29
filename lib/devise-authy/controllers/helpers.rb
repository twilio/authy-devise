module DeviseAuthy
  module Controllers
    module Helpers
      extend ActiveSupport::Concern

      included do
        before_filter :handle_devise_authy
      end

      private

      def handle_devise_authy
        if !request.format.nil? and request.format.html? and !devise_controller?
          Devise.mappings.keys.flatten.any? do |scope|
            if signed_in?(scope) && warden.session(scope)[:with_authy_authentication]
              id = warden.session(scope)[:id]
              warden.logout
              session["#{scope}_id"] = id
              session["#{scope}_return_to"] = request.path if request.get?

              redirect_to devise_authy_path_for(scope)
              return
            end
          end
        end
      end

      def devise_authy_path_for(resource_or_scope = nil)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        change_path = "#{scope}_devise_authy_path"
        send(change_path)
      end
    end
  end
end
