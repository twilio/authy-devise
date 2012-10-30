require 'spec_helper'

describe "routes for devise_authy" do
  it "route to devise_authy#show" do
    get('/users/devise_authy').should route_to("devise/devise_authy#show")
  end

  it "routes to devise_authy#create" do
    post('/users/devise_authy').should route_to("devise/devise_authy#create")
  end

  it "routes to devise_authy#update" do
    put('/users/devise_authy').should route_to("devise/devise_authy#update")
  end

  it "map enable two factor authentication" do
    get('/users/enable_authy').should route_to("devise/devise_authy#register")
  end
end
