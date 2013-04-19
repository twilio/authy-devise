RailsApp::Application.routes.draw do
  get "welcome/index"

  devise_for :users

  root :to => 'welcome#index'
end
