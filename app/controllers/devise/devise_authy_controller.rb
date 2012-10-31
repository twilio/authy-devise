class Devise::DeviseAuthyController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [:show, :update]
  prepend_before_filter :authenticate_scope!, :only => [:register, :create]
  include Devise::Controllers::Helpers

  def show
    @authy_id = session['user_id']
    render :show
  end

  def update
    resource = resource_class.find_by_authy_id(params[resource_name]['authy_id'])
    token = Authy::API.verify(:id => params[resource_name][:authy_id], :token => params[resource_name][:token])
    if !resource.nil? && token.ok?
      resource.last_sign_in_with_authy = DateTime.now
      resource.save
      cookies[:authy_authentication] = {:value => true, :expires => Time.now + 1.month}
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      redirect_to :root
    end
  end

  def register
    render :register
  end

  def create
    @authy_user = Authy::API.register_user(
      :email => resource.email,
      :cellphone => params[:user][:cellphone],
      :country_code => params[:user][:country_code]
    )

    if @authy_user.ok?
      resource.authy_id = @authy_user.id
      resource.save
      set_flash_message(:notice, 'Two factor authentication was enable')
      redirect_to :root
    else
      set_flash_message(:error, 'Something went wrong while enabling two factor authentication')
      render :register
    end
  end

  private

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send("current_#{resource_name}")
  end
end
