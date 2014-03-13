require 'spec_helper'

describe Devise::DeviseCertificateController do
  include Devise::TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user(:certificate_id => 2)
  end

  describe "GET #verify_certificate" do
    it "Should render the second step of authentication" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
      get :GET_verify_certificate
      response.should render_template('verify_certificate')
    end

    it "Should no render the second step of authentication if first step is incomplete" do
      request.session["user_id"] = @user.id
      get :GET_verify_certificate
      response.should redirect_to(root_url)
    end

    it "should redirect to root_url" do
      get :GET_verify_certificate
      response.should redirect_to(root_url)
    end
  end

  describe "POST #verify_certificate" do
    it "Should login the user if token is ok" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
			pending
      post :POST_verify_certificate, :token => '0000000'
      @user.reload
      @user.last_sign_in_with_certificate.should_not be_nil

      response.cookies["remember_device"].should be_nil
      response.should redirect_to(root_url)
      flash.now[:notice].should_not be_nil
    end

    it "Should set remember_device if selected" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
			pending
      post :POST_verify_certificate, :token => '0000000', :remember_device => '1'
      @user.reload
      @user.last_sign_in_with_certificate.should_not be_nil

      response.cookies["remember_device"].should_not be_nil
      response.should redirect_to(root_url)
      flash.now[:notice].should_not be_nil
    end

    it "Shouldn't login the user if token is invalid" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
			pending
      post :POST_verify_certificate, :token => '5678900'
      response.should render_template('verify_certificate')
    end
  end

  describe "GET #enable_certificate" do
    it "Should render enable certificate view" do
      user2 = create_user
      sign_in user2
      get :GET_enable_certificate
      response.should render_template('enable_certificate')
    end

    it "Shouldn't render enable certificate view" do
      get :GET_enable_certificate
      response.should redirect_to(new_user_session_url)
    end

    it "should redirect if user has certificate enabled" do
      @user.update_attribute(:certificate_enabled, true)
      sign_in @user
      get :GET_enable_certificate
      response.should redirect_to(root_url)
      flash.now[:notice].should == "Certificate authentication is already enabled."
    end

    it "Should render enable certificate view if certificate enabled is false" do
      sign_in @user
      get :GET_enable_certificate
      response.should render_template('enable_certificate')
    end
  end

  describe "POST #enable_certificate" do
    it "Should create user in certificate application" do
      user2 = create_user
      sign_in user2
			pending
      post :POST_enable_certificate, :cellphone => '2222227', :country_code => '57'
      user2.reload
      user2.certificate_id.should_not be_nil
      flash.now[:notice].should == "Two factor authentication was enabled"
      response.should redirect_to(user_verify_certificate_installation_url)
    end

    it "Should not create user register user failed" do
      user2 = create_user
      sign_in user2
			pending
      post :POST_enable_certificate, :cellphone => '22222', :country_code => "57"
      response.should render_template('enable_certificate')
      flash[:error].should == "Something went wrong while enabling two factor authentication"
    end

    it "Should redirect if user isn't authenticated" do
      post :POST_enable_certificate, :cellphone => '3010008090', :country_code => '57'
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "GET #verify_certificate_installation" do
    it "Should render the certificate installation page" do
      sign_in @user
      get :GET_verify_certificate_installation
      response.should render_template('verify_certificate_installation')
    end

    it "Should redirect if user isn't authenticated" do
      get :GET_verify_certificate_installation
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST #verify_certificate_installation" do
    it "Should enable certificate for user" do
      sign_in @user
			pending
    end

    it "should not enable certificate for user" do
      sign_in @user
			pending
    end

    it "Should redirect if user isn't authenticated" do
      get :GET_verify_certificate_installation
      response.should redirect_to(new_user_session_url)
    end
  end
end
