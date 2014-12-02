class DeviseAuthy::PasswordsController < Devise::PasswordsController
  def sign_in(resource_or_scope, *args)
    resource = args.last || resource_or_scope

    if resource.respond_to?(:with_authy_authentication?) && resource.with_authy_authentication?(request)
      # Do nothing. Because we need verify the 2FA
      true
    else
      super
    end
  end
end
