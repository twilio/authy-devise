class DeviseAuthy::PasswordsController < Devise::PasswordsController
  ##
  # In the passwords controller a user can update their password using a
  # recovery token. If `Devise.sign_in_after_reset_password` is `true` then the
  # user is signed in immediately with the
  # `Devise::Controllers::SignInOut#sign_in` method. However, if the user has
  # 2FA enabled they should enter their second factor before they are signed in.
  #
  # This method overrides `Devise::Controllers::SignInOut#sign_in` but only
  # within the `Devise::PasswordsController`. If the user needs to verify 2FA
  # then `sign_in` returns `true`. This short circuits the method before it can
  # call `warden.set_user` and log the user in.
  #
  # The user is redirected to `after_resetting_password_path_for(user)` at which
  # point, since the user is not logged in, redirects again to sign in.
  #
  # This doesn't retain the expected behaviour of
  # `Devise.sign_in_after_reset_password`, but is forgivable because this
  # shouldn't be an avenue to bypass 2FA.
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
