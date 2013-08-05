module ActionDispatch::Routing
  class Mapper
    protected

    def devise_authy(mapping, controllers)
      match "/#{mapping.path_names[:verify_authy]}", :controller => controllers[:devise_authy], :action => :GET_verify_authy, :as => :verify_authy, :via => :get
      match "/#{mapping.path_names[:verify_authy]}", :controller => controllers[:devise_authy], :action => :POST_verify_authy, :as => nil, :via => :post

      match "/#{mapping.path_names[:enable_authy]}", :controller => controllers[:devise_authy], :action => :GET_enable_authy, :as => :enable_authy, :via => :get
      match "/#{mapping.path_names[:enable_authy]}", :controller => controllers[:devise_authy], :action => :POST_enable_authy, :as => nil, :via => :post

      match "/#{mapping.path_names[:verify_authy_installation]}", :controller => controllers[:devise_authy], :action => :GET_verify_authy_installation, :as => :verify_authy_installation, :via => :get
      match "/#{mapping.path_names[:verify_authy_installation]}", :controller => controllers[:devise_authy], :action => :POST_verify_authy_installation, :as => nil, :via => :post


      match "/request-sms", :controller => controllers[:devise_authy], :action => :request_sms, :as => :request_sms, :via => :post
    end
  end
end

