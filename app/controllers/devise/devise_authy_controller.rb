class Devise::DeviseAuthyController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [:show, :update]
  prepend_before_filter :authenticate_scope!, :only => [:register, :create]
  include Devise::Controllers::Helpers

  def show
    @resource = resource_class.find_by_id(session["#{resource_name}_id"])

    if @resource && session[:"#{resource_name}_password_checked"].to_s == "true"
      @authy_id = @resource.authy_id
      render :show
    else
      redirect_to :root
    end
  end

  # verify 2fa
  def update
    @resource = resource_class.find_by_id(session["#{resource_name}_id"])
    if !@resource
      redirect_to :root and return
    end

    token = Authy::API.verify({
      :id => @resource.authy_id,
      :token => params[:token],
      :force => true
    })

    if token.ok? && session[:"#{resource_name}_password_checked"].to_s == "true"
      @resource.update_attribute(:last_sign_in_with_authy, DateTime.now)

      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, @resource)
      respond_with resource, :location => after_sign_in_path_for(@resource)
    else
      render :show
    end
  end

  # enable 2fa
  def register
    render :register
  end

  def create
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
      end
      redirect_to :root
    else
      set_flash_message(:error, :not_enabled)
      render :register
    end
  end

  private

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send("current_#{resource_name}")
  end
end
