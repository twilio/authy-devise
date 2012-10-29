class Devise::DeviseAuthyController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [:show, :update, :register, :create]
  include Devise::Controllers::Helpers

  def show
    @tmpid = session['user_id']
    render :show
  end

  def update
    resource = resource_class.find_by_authy_id(params[resource_name]['tmpid'])
    token = Authy::API.verify(:id => params[resource_name][:tmpid], :token => params[resource_name][:token])
    if token.ok?
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
  end
end
