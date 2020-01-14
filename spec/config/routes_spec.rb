# frozen_string_literal: true

RSpec.describe "routes with devise_authy", type: :controller do
  describe "with default devise_for" do
    it "route to devise_authy#GET_verify_authy" do
      expect(get: '/users/verify_authy').to route_to("devise/devise_authy#GET_verify_authy")
    end

    it "routes to devise_authy#POST_verify_authy" do
      expect(post: '/users/verify_authy').to route_to("devise/devise_authy#POST_verify_authy")
    end

    it "routes to devise_authy#GET_enable_authy" do
      expect(get: '/users/enable_authy').to route_to("devise/devise_authy#GET_enable_authy")
    end

    it "routes to devise_authy#POST_enable_authy" do
      expect(post: '/users/enable_authy').to route_to("devise/devise_authy#POST_enable_authy")
    end

    it "routes to devise_authy#POST_disable_authy" do
      expect(post: '/users/disable_authy').to route_to("devise/devise_authy#POST_disable_authy")
    end

    it "route to devise_authy#GET_verify_authy_installation" do
      expect(get: '/users/verify_authy_installation').to route_to("devise/devise_authy#GET_verify_authy_installation")
    end

    it "routes to devise_authy#POST_verify_authy_installation" do
      expect(post: '/users/verify_authy_installation').to route_to("devise/devise_authy#POST_verify_authy_installation")
    end

    it "routes to devise_authy#request_sms" do
      expect(post: '/users/request-sms').to route_to("devise/devise_authy#request_sms")
    end

    it "routes to devise_authy#request_phone_call" do
      expect(post: '/users/request-phone-call').to route_to("devise/devise_authy#request_phone_call")
    end

    it "routes to devise_authy#GET_authy_onetouch_status" do
      expect(get: '/users/authy_onetouch_status').to route_to("devise/devise_authy#GET_authy_onetouch_status")
    end
  end

  describe "with customised mapping" do
    # See routing in spec/internal/config/routes.rb for the mapping
    it "updates to new routes set in the mapping" do
      expect(get: '/lockable_users/verify-token').to route_to("devise/devise_authy#GET_verify_authy")
      expect(post: '/lockable_users/verify-token').to route_to("devise/devise_authy#POST_verify_authy")
      expect(get: '/lockable_users/enable-two-factor').to route_to("devise/devise_authy#GET_enable_authy")
      expect(post: '/lockable_users/enable-two-factor').to route_to("devise/devise_authy#POST_enable_authy")
      expect(get: '/lockable_users/verify-installation').to route_to("devise/devise_authy#GET_verify_authy_installation")
      expect(post: '/lockable_users/verify-installation').to route_to("devise/devise_authy#POST_verify_authy_installation")
      expect(get: '/lockable_users/onetouch-status').to route_to("devise/devise_authy#GET_authy_onetouch_status")
    end

    it "doesn't change routes not in custom mapping" do
      expect(post: '/lockable_users/disable_authy').to route_to("devise/devise_authy#POST_disable_authy")
      expect(post: '/lockable_users/request-sms').to route_to("devise/devise_authy#request_sms")
      expect(post: '/lockable_users/request-phone-call').to route_to("devise/devise_authy#request_phone_call")
    end
  end
end
