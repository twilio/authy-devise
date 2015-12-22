class Devise::DeviseAuthyController < DeviseController
  prepend_before_filter :find_resource, :only => [
    :request_phone_call, :request_sms
  ]
  prepend_before_filter :find_resource_and_require_password_checked, :only => [
    :GET_verify_authy, :POST_verify_authy
  ]
  prepend_before_filter :authenticate_scope!, :only => [
    :GET_enable_authy, :POST_enable_authy,
    :GET_verify_authy_installation, :POST_verify_authy_installation,
    :POST_disable_authy
  ]
  include Devise::Controllers::Helpers

  def GET_verify_authy
    @authy_id = @resource.authy_id
    render :verify_authy
  end

  # verify 2fa
  def POST_verify_authy
    token = Authy::API.verify({
      :id => @resource.authy_id,
      :token => params[:token],
      :force => true
    })

    if token.ok?
      @resource.update_attribute(:last_sign_in_with_authy, DateTime.now)

      session["#{resource_name}_authy_token_checked"] = true

      remember_device if params[:remember_device].to_i == 1
      if session.delete("#{resource_name}_remember_me") == true && @resource.respond_to?(:remember_me=)
        @resource.remember_me = true
      end
      sign_in(resource_name, @resource)

      set_flash_message(:notice, :signed_in) if is_navigational_format?
      respond_with resource, :location => after_sign_in_path_for(@resource)
    else
      handle_invalid_token :verify_authy, :invalid_token
    end
  end

  # enable 2fa
  def GET_enable_authy
    if resource.authy_id.blank? || !resource.authy_enabled
      render :enable_authy
    else
      set_flash_message(:notice, :already_enabled)
      redirect_to after_authy_enabled_path_for(resource)
    end
  end

  def POST_enable_authy
    @authy_user = Authy::API.register_user(
      :email => resource.email,
      :cellphone => params[:cellphone],
      :country_code => params[:country_code]
    )

    if @authy_user.ok?
      resource.authy_id = @authy_user.id
      if resource.save
        set_flash_message(:notice, :enabled)
      else
        set_flash_message(:error, :not_enabled)
        redirect_to after_authy_enabled_path_for(resource) and return
      end

      redirect_to [resource_name, :verify_authy_installation]
    else
      set_flash_message(:error, :not_enabled)
      render :enable_authy
    end
  end

  # Disable 2FA
  def POST_disable_authy
    response = Authy::API.delete_user(:id => resource.authy_id)

    if response.ok?
      resource.update_attribute(:authy_enabled, false)
      resource.update_attribute(:authy_id, nil)

      set_flash_message(:notice, :disabled)
    else
      set_flash_message(:error, :not_disabled)
    end

    redirect_to after_authy_disabled_path_for(resource)
  end

  def GET_verify_authy_installation
    render :verify_authy_installation
  end

  def POST_verify_authy_installation
    token = Authy::API.verify({
      :id => self.resource.authy_id,
      :token => params[:token],
      :force => true
    })

    self.resource.authy_enabled = token.ok?

    if token.ok? && self.resource.save
      set_flash_message(:notice, :enabled)
      redirect_to after_authy_verified_path_for(resource)
    else
      handle_invalid_token :verify_authy_installation, :not_enabled
    end
  end

  def request_phone_call
    unless @resource
      render :json => { :sent => false, :message => "User couldn't be found." }
      return
    end

    response = Authy::API.request_phone_call(:id => @resource.authy_id, :force => true)
    render :json => { :sent => response.ok?, :message => response.message }
  end

  def request_sms
    if !@resource
      render :json => {:sent => false, :message => "User couldn't be found."}
      return
    end

    response = Authy::API.request_sms(:id => @resource.authy_id, :force => true)
    render :json => {:sent => response.ok?, :message => response.message}
  end

  private

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send("current_#{resource_name}")
    @resource = resource
  end

  def find_resource
    @resource = send("current_#{resource_name}")

    if @resource.nil?
      @resource = resource_class.find_by_id(session["#{resource_name}_id"])
    end
  end

  def find_resource_and_require_password_checked
    find_resource

    if @resource.nil? || session[:"#{resource_name}_password_checked"].to_s != "true"
      redirect_to invalid_resource_path
    end
  end

  protected

  def after_authy_enabled_path_for(resource)
    root_path
  end

  def after_authy_verified_path_for(resource)
    after_authy_enabled_path_for(resource)
  end

  def after_authy_disabled_path_for(resource)
    root_path
  end

  def invalid_resource_path
    root_path
  end

  def handle_invalid_token(view, error_message)
    if @resource.respond_to?(:invalid_authy_attempt!) && @resource.invalid_authy_attempt!
      after_account_is_locked
    else
      set_flash_message(:error, error_message)
      render view
    end
  end

  def after_account_is_locked
    sign_out_and_redirect @resource
  end
end
