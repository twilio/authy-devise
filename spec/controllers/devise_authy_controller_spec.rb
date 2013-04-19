require 'spec_helper'

describe Devise::DeviseAuthyController do
  include Devise::TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user(:authy_id => 2)
  end

  describe "GET #verify_authy" do
    it "Should render the second step of authentication" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
      get :GET_verify_authy
      response.should render_template('verify_authy')
    end

    it "Should no render the second step of authentication if first step is incomplete" do
      request.session["user_id"] = @user.id
      get :GET_verify_authy
      response.should redirect_to(root_url)
    end

    it "should redirect to root_url" do
      get :GET_verify_authy
      response.should redirect_to(root_url)
    end
  end

  describe "POST #verify_authy" do
    it "Should login the user if token is ok" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true

      post :POST_verify_authy, :token => '0000000'
      @user.reload
      @user.last_sign_in_with_authy.should_not be_nil
      response.should redirect_to(root_url)
      flash.now[:notice].should_not be_nil
    end

    it "Shouldn't login the user if token is invalid" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true

      post :POST_verify_authy, :token => '5678900'
      response.should render_template('verify_authy')
    end
  end

  describe "GET #enable_authy" do
    it "Should render enable authy view" do
      sign_in @user
      get :GET_enable_authy
      response.should render_template('enable_authy')
    end

    it "Shouldn't render enable authy view" do
      get :GET_enable_authy
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST #enable_authy" do
    it "Should create user in authy application" do
      user2 = create_user
      sign_in user2

      post :POST_enable_authy, :cellphone => '2222227', :country_code => '57'
      user2.reload
      user2.authy_id.should_not be_nil
      flash.now[:notice].should == "Two factor authentication was enable"
      response.should redirect_to(user_verify_authy_installation_url)
    end

    it "Should not create user register user failed" do
      user2 = create_user
      sign_in user2

      post :POST_enable_authy, :cellphone => '22222', :country_code => "57"
      response.should render_template('enable_authy')
      flash[:error].should == "Something went wrong while enabling two factor authentication"
    end

    it "Should redirect if user isn't authenticated" do
      post :POST_enable_authy, :cellphone => '3010008090', :country_code => '57'
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "GET #verify_authy_installation" do
    it "Should render the authy installation page" do
      sign_in @user
      get :GET_verify_authy_installation
      response.should render_template('verify_authy_installation')
    end

    it "Should redirect if user isn't authenticated" do
      get :GET_verify_authy_installation
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST #verify_authy_installation" do
    it "Should enable authy for user" do
      sign_in @user
      post :POST_verify_authy_installation, :token => "0000000"
      response.should redirect_to(root_url)
      flash[:notice].should == 'Two factor authentication was enable'
    end

    it "should not enable authy for user" do
      sign_in @user
      post :POST_verify_authy_installation, :token => "0007777"
      response.should render_template('verify_authy_installation')
      flash[:error].should == 'Something went wrong while enabling two factor authentication'
    end

    it "Should redirect if user isn't authenticated" do
      get :GET_verify_authy_installation
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST #request_sms" do
    it "Should send sms if user is logged" do
      sign_in @user
      post :request_sms
      response.content_type.should == 'application/json'
      body = JSON.parse(response.body)
      body['sent'].should be_true
      body['message'].should == "SMS token was sent"
    end

    it "Shoul not send sms if user couldn't be found" do
      post :request_sms
      response.content_type.should == 'application/json'
      body = JSON.parse(response.body)
      body['sent'].should be_false
      body['message'].should == "User couldn't be found."
    end
  end
end