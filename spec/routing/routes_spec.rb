require 'spec_helper'

describe "routes for devise_authy" do
  it "route to devise_authy#GET_verify_authy" do
		pending 'example'
    get('/users/verify_authy').should route_to("devise/devise_authy#GET_verify_authy")
  end
end
