class WelcomeController < ApplicationController
  before_filter :authenticate_scope!

  def index
  end

  def authenticate_scope!
    scope = lockable_user_signed_in? ? 'lockable_user'
                                     : 'user'
    Rails.logger.debug "\nauthenticate_#{scope}!"
    send "authenticate_#{scope}!", force: true
  end
end
