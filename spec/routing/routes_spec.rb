require 'spec_helper'

describe "routes for devise_authy" do
  it "route to devise_authy#GET_verify_authy" do
    get('/users/verify_authy').should route_to("devise/devise_authy#GET_verify_authy")
  end

  it "routes to devise_authy#POST_verify_authy" do
    post('/users/verify_authy').should route_to("devise/devise_authy#POST_verify_authy")
  end

  it "routes to devise_authy#GET_enable_authy" do
    get('/users/enable_authy').should route_to("devise/devise_authy#GET_enable_authy")
  end

  it "routes to devise_authy#POST_enable_authy" do
    post('/users/enable_authy').should route_to("devise/devise_authy#POST_enable_authy")
  end

  it "route to devise_authy#GET_verify_authy_installation" do
    get('/users/verify_authy_installation').should route_to("devise/devise_authy#GET_verify_authy_installation")
  end

  it "routes to devise_authy#POST_verify_authy_installation" do
    post('/users/verify_authy_installation').should route_to("devise/devise_authy#POST_verify_authy_installation")
  end

  it "routes to devise_authy#request_sms" do
    post('/users/request-sms').should route_to("devise/devise_authy#request_sms")
  end
end
