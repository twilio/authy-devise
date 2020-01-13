# frozen_string_lxiteral: true

RSpec.describe "routes for devise_authy", type: :controller do
  it "route to devise_authy#GET_verify_authy" do
    expect(:get => '/users/sign_in').to route_to("devise/sessions#new")
    expect(:get => '/users/verify_authy').to route_to("devise/devise_authy#GET_verify_authy")
  end

  xit "routes to devise_authy#POST_verify_authy" do
    expect(post('/users/verify_authy')).to route_to("devise/devise_authy#POST_verify_authy")
  end

  xit "routes to devise_authy#GET_enable_authy" do
    expect(get('/users/enable_authy')).to route_to("devise/devise_authy#GET_enable_authy")
  end

  xit "routes to devise_authy#POST_enable_authy" do
    expect(post('/users/enable_authy')).to route_to("devise/devise_authy#POST_enable_authy")
  end

  xit "route to devise_authy#GET_verify_authy_installation" do
    expect(get('/users/verify_authy_installation')).to route_to("devise/devise_authy#GET_verify_authy_installation")
  end

  xit "routes to devise_authy#POST_verify_authy_installation" do
    expect(post('/users/verify_authy_installation')).to route_to("devise/devise_authy#POST_verify_authy_installation")
  end

  xit "routes to devise_authy#request_sms" do
    expect(post('/users/request-sms')).to route_to("devise/devise_authy#request_sms")
  end

  xit "routes to devise_authy#GET_authy_onetouch_status" do
    expect(get('/users/authy_onetouch_status')).to route_to("devise/devise_authy#GET_authy_onetouch_status")
  end
end
