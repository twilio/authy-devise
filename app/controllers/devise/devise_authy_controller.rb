class Devise::DeviseAuthyController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [:show, :update]
  include Devise::Controllers::Helpers

  def show
    @authy_id = session['user_id']
    render :show
  end

  def update
    resource = resource_class.find_by_authy_id(params[resource_name]['authy_id'])
    token = Authy::API.verify(:id => params[resource_name][:authy_id], :token => params[resource_name][:token])
    if !resource.nil? && token.ok?
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
    resource = send("current_#{resource_name}")

    @authy_user = Authy::API.register_user(
      :email => resource.email,
      :cellphone => params[:user][:cellphone],
      :country_code => params[:user][:country_code]
    )

    if @authy_user.ok?
      resource.authy_id = @authy_id.id
      resource.save
      set_flash_message(:notice, 'Two factor authentication was enable')
      redirect_to :root
    else
      set_flash_message(:error, 'Something went wrong while enabling two factor authentication')
      render :register
    end
  end
end
