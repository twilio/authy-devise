class WelcomeController < ApplicationController
  before_filter :authenticate_user!, only: "user_page"
  before_filter :authenticate_admin!, only: "admin_page"

  def index
    redirect_to welcome_admin_page_path if current_admin
    redirect_to welcome_user_page_path if current_user
  end

  def admin_page
  end

  def user_page
  end
end
