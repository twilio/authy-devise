module ActionDispatch::Routing
  class Mapper
    protected

    def devise_authy(mapping, controllers)
      resource :devise_authy, :only => [:show, :update, :create], :path => mapping.path_names[:devise_authy], :controller => controllers[:devise_authy]
      match '/enable-two-factor', :controller => controllers[:devise_authy], :action => :register, :as => :enable_authy, :via => :get
    end
  end
end
