class Devise::DeviseCertificateController < DeviseController
  prepend_before_filter :find_resource, :only => [
    :request_sms
  ]
  prepend_before_filter :find_resource_and_require_password_checked, :only => [
    :GET_verify_certificate, :POST_verify_certificate
  ]
  prepend_before_filter :authenticate_scope!, :only => [
    :GET_enable_certificate, :POST_enable_certificate,
    :GET_verify_certificate_installation, :POST_verify_certificate_installation
  ]
  include Devise::Controllers::Helpers

  def GET_verify_certificate
    @certificate_id = @resource.certificate_id
    render :verify_certificate
  end

  # verify 2fa
  def POST_verify_certificate
    token = Certificate::API.verify({
      :id => @resource.certificate_id,
      :token => params[:token],
      :force => true
    })

    if token.ok?
      @resource.update_attribute(:last_sign_in_with_certificate, DateTime.now)

      remember_device if params[:remember_device].to_i == 1
      if session.delete("#{resource_name}_remember_me") == true && @resource.respond_to?(:remember_me=)
        @resource.remember_me = true
      end
      sign_in(resource_name, @resource)

      set_flash_message(:notice, :signed_in) if is_navigational_format?
      respond_with resource, :location => after_sign_in_path_for(@resource)
    else
      set_flash_message(:error, :invalid_token)
      render :verify_certificate
    end
  end

  # enable 2fa
  def GET_enable_certificate
    if resource.certificate_id.blank? || !resource.certificate_enabled
      render :enable_certificate
    else
      set_flash_message(:notice, :already_enabled)
      redirect_to after_certificate_enabled_path_for(resource)
    end
  end

  def POST_enable_certificate
    @certificate_user = Certificate::API.register_user(
      :email => resource.email,
      :cellphone => params[:cellphone],
      :country_code => params[:country_code]
    )

    if @certificate_user.ok?
      resource.certificate_id = @certificate_user.id
      if resource.save
        set_flash_message(:notice, :enabled)
      else
        set_flash_message(:error, :not_enabled)
        redirect_to after_certificate_enabled_path_for(resource) and return
      end

      redirect_to [resource_name, :verify_certificate_installation]
    else
      set_flash_message(:error, :not_enabled)
      render :enable_certificate
    end
  end

  def GET_verify_certificate_installation
    render :verify_certificate_installation
  end

  def POST_verify_certificate_installation
    token = Certificate::API.verify({
      :id => self.resource.certificate_id,
      :token => params[:token],
      :force => true
    })

    self.resource.certificate_enabled = token.ok?
    if !token.ok? || !self.resource.save
      set_flash_message(:error, :not_enabled)
      render :verify_certificate_installation
    else
      set_flash_message(:notice, :enabled)
      redirect_to after_certificate_verified_path_for(resource)
    end
  end

  private

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send("current_#{resource_name}")
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

    def after_certificate_enabled_path_for(resource)
      root_path
    end

    def after_certificate_verified_path_for(resource)
      after_certificate_enabled_path_for(resource)
    end

    def invalid_resource_path
      root_path
    end

		def certificate
			request.cgi.env_table['SSL_CLIENT_CERT'].gsub(/(\n|-----(BEGIN|END) CERTIFICATE-----)/, '');
		end
end
