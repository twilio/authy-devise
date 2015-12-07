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

      response.cookies["remember_device"].should be_nil
      response.should redirect_to(root_url)
      flash.now[:notice].should_not be_nil
    end

    it "Should set remember_device if selected" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true

      post :POST_verify_authy, :token => '0000000', :remember_device => '1'
      @user.reload
      @user.last_sign_in_with_authy.should_not be_nil

      response.cookies["remember_device"].should_not be_nil
      response.should redirect_to(root_url)
      flash.now[:notice].should_not be_nil
    end

    it "Shouldn't login the user if token is invalid" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true

      post :POST_verify_authy, :token => '5678900'
      response.should render_template('verify_authy')
    end

    context 'User is lockable' do

      let(:user) { create_lockable_user authy_id: 2 }

      before do
        controller.stub(:find_resource).and_return user
        controller.instance_variable_set :@resource, user
      end

      it 'locks the account when failed_attempts exceeds maximum' do
        request.session['user_id']               = user.id
        request.session['user_password_checked'] = true

        too_many_failed_attempts.times do
          post :POST_verify_authy, token: invalid_authy_token
        end

        user.reload
        expect(user.access_locked?).to be_true
      end

    end

    context 'User is not lockable' do

      it 'does not lock the account when failed_attempts exceeds maximum' do
        request.session['user_id']               = @user.id
        request.session['user_password_checked'] = true

        too_many_failed_attempts.times do
          post :POST_verify_authy, token: invalid_authy_token
        end

        @user.reload
        expect(@user.locked_at).to be_nil
      end

    end

  end

  describe "GET #enable_authy" do
    it "Should render enable authy view" do
      user2 = create_user
      sign_in user2
      get :GET_enable_authy
      response.should render_template('enable_authy')
    end

    it "Shouldn't render enable authy view" do
      get :GET_enable_authy
      response.should redirect_to(new_user_session_url)
    end

    it "should redirect if user has authy enabled" do
      @user.update_attribute(:authy_enabled, true)
      sign_in @user
      get :GET_enable_authy
      response.should redirect_to(root_url)
      flash.now[:notice].should == "Two factor authentication is already enabled."
    end

    it "Should render enable authy view if authy enabled is false" do
      sign_in @user
      get :GET_enable_authy
      response.should render_template('enable_authy')
    end
  end

  describe "POST #enable_authy" do
    it "Should create user in authy application" do
      user2 = create_user
      sign_in user2

      post :POST_enable_authy, :cellphone => '2222227', :country_code => '57'
      user2.reload
      user2.authy_id.should_not be_nil
      flash.now[:notice].should == "Two factor authentication was enabled"
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

  describe "POST #disable_authy" do
    it "Should disable 2FA" do
      sign_in @user
      @user.update_attribute(:authy_enabled, true)

      post :POST_disable_authy
      @user.reload
      @user.authy_id.should be_nil
      @user.authy_enabled.should be_false
      flash.now[:notice].should == "Two factor authentication was disabled"
      response.should redirect_to(root_url)
    end

    it "Should not disable 2FA" do
      sign_in @user
      @user.update_attribute(:authy_enabled, true)

      authy_response = mock('authy_response')
      authy_response.stub(:ok?).and_return(false)
      Authy::API.should_receive(:delete_user).with(:id => @user.authy_id.to_s).and_return(authy_response)

      post :POST_disable_authy
      @user.reload
      @user.authy_id.should_not be_nil
      @user.authy_enabled.should be_true
      flash[:error].should == "Something went wrong while disabling two factor authentication"
    end

    it "Should redirect if user isn't authenticated" do
      post :POST_disable_authy
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
      flash[:notice].should == 'Two factor authentication was enabled'
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

  describe "POST #request_phone_call" do
    it "Should send phone call if user is logged" do
      sign_in @user
      post :request_phone_call
      response.content_type.should == 'application/json'
      body = JSON.parse(response.body)
      body['sent'].should be_true
      body['message'].should == "Call started..."
    end

    it "Shoul not send phone call if user couldn't be found" do
      post :request_phone_call
      response.content_type.should == 'application/json'
      body = JSON.parse(response.body)
      body['sent'].should be_false
      body['message'].should == "User couldn't be found."
    end
  end
end
