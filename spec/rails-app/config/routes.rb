RailsApp::Application.routes.draw do
  get "welcome/index"

  devise_for :users
  devise_for :lockable_users, class: 'LockableUser' # for testing authy_lockable

  root :to => 'welcome#index'
end
