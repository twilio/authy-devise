module ActionDispatch::Routing
  class Mapper
    protected

    def devise_certificate(mapping, controllers)
      match "/#{mapping.path_names[:verify_certificate]}", :controller => controllers[:devise_certificate], :action => :GET_verify_certificate, :as => :verify_certificate, :via => :get
      match "/#{mapping.path_names[:verify_certificate]}", :controller => controllers[:devise_certificate], :action => :POST_verify_certificate, :as => nil, :via => :post

      match "/#{mapping.path_names[:enable_certificate]}", :controller => controllers[:devise_certificate], :action => :GET_enable_certificate, :as => :enable_certificate, :via => :get
      match "/#{mapping.path_names[:enable_certificate]}", :controller => controllers[:devise_certificate], :action => :POST_enable_certificate, :as => nil, :via => :post

      match "/#{mapping.path_names[:verify_certificate_installation]}", :controller => controllers[:devise_certificate], :action => :GET_verify_certificate_installation, :as => :verify_certificate_installation, :via => :get
      match "/#{mapping.path_names[:verify_certificate_installation]}", :controller => controllers[:devise_certificate], :action => :POST_verify_certificate_installation, :as => nil, :via => :post
    end
  end
end

