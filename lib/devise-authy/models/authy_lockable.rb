module Devise

  module Models

    # Handles blocking a user access after a certain number of attempts.
    # Requires proper configuration of the Devise::Models::Lockable module.
    #
    module AuthyLockable

      extend ActiveSupport::Concern

      # Public: Determine if this is a lockable resource, via Devise::Models::Lockable.
      # Returns true
      # Raises an error if the Devise::Models::Lockable module is not configured.
      def lockable?
        raise 'Devise lockable extension required' unless respond_to? :lock_access!
        Devise.lock_strategy == :failed_attempts
      end

      # Public: Handle a failed 2FA attempt. If the resource is lockable via
      # Devise::Models::Lockable module then enforce that setting.
      #
      # Returns true if the user is locked out.
      def invalid_authy_attempt!
        return false unless lockable?

        self.failed_attempts ||= 0
        self.failed_attempts += 1

        if attempts_exceeded?
          lock_access! unless access_locked?
          true
        else
          save validate: false
          false
        end
      end

    end

  end

end
