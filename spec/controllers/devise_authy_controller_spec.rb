require 'spec_helper'

describe Devise::DeviseAuthyController, type: :controller do
  include Devise::Test::ControllerHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user(:authy_id => 2)
  end

  describe "GET #verify_authy" do
    describe "when the first step of authentication is complete" do
      before do
        request.session["user_id"] = @user.id
        request.session["user_password_checked"] = true
      end

      it "Should render the second step of authentication" do
        get :GET_verify_authy
        expect(response).to render_template('verify_authy')
      end

      it "should not make a OneTouch request" do
        expect(Authy::OneTouch).not_to receive(:send_approval_request)
        get :GET_verify_authy
      end

      describe "when OneTouch is enabled" do
        before do
          allow(User).to receive(:authy_enable_onetouch).and_return(true)
        end

        it "should make a OneTouch request" do
          expect(Authy::OneTouch).to receive(:send_approval_request)
                                 .with(id: @user.authy_id, message: 'Request to Login')
                                 .and_return('approval_request' => { 'uuid' => 'uuid' }).once
          get :GET_verify_authy
        end
      end
    end

    it "Should no render the second step of authentication if first step is incomplete" do
      request.session["user_id"] = @user.id
      get :GET_verify_authy
      expect(response).to redirect_to(root_url)
    end

    it "should redirect to root_url" do
      get :GET_verify_authy
      expect(response).to redirect_to(root_url)
    end

    it "should not make a OneTouch request" do
      expect(Authy::OneTouch).not_to receive(:send_approval_request)
      get :GET_verify_authy
    end
  end

  describe "POST #verify_authy" do
    let(:verify_success) { double("Authy::Response", :ok? => true) }
    let(:verify_failure) { double("Authy::Response", :ok? => false) }

    it "Should login the user if token is ok" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true

      expect(Authy::API).to receive(:verify).with(
        :id => @user.authy_id,
        :token => valid_authy_token,
        :force => true
      ).and_return(verify_success)

      post :POST_verify_authy, :token => valid_authy_token
      @user.reload
      expect(@user.last_sign_in_with_authy).not_to be_nil

      expect(response.cookies["remember_device"]).to be_nil
      expect(response).to redirect_to(root_url)
      expect(flash.now[:notice]).not_to be_nil
      expect(session["user_authy_token_checked"]).to be_truthy
    end

    it "Should set remember_device if selected" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true

      expect(Authy::API).to receive(:verify).with(
        :id => @user.authy_id,
        :token => valid_authy_token,
        :force => true
      ).and_return(verify_success)

      post :POST_verify_authy, :token => valid_authy_token, :remember_device => '1'
      @user.reload
      expect(@user.last_sign_in_with_authy).not_to be_nil

      expect(response.cookies["remember_device"]).not_to be_nil
      expect(response).to redirect_to(root_url)
      expect(flash.now[:notice]).not_to be_nil
    end

    it "Shouldn't login the user if token is invalid" do
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true

      expect(Authy::API).to receive(:verify).with(
        :id => @user.authy_id,
        :token => invalid_authy_token,
        :force => true
      ).and_return(verify_failure)

      post :POST_verify_authy, :token => invalid_authy_token
      expect(response).to render_template('verify_authy')
    end

    context 'User is lockable' do

      let(:user) { create_lockable_user authy_id: 2 }

      before do
        allow(controller).to receive(:find_resource).and_return user
        controller.instance_variable_set :@resource, user
      end

      it 'locks the account when failed_attempts exceeds maximum' do
        request.session['user_id']               = user.id
        request.session['user_password_checked'] = true

        expect(Authy::API).to receive(:verify).exactly(Devise.maximum_attempts).times.with(
          :id => @user.authy_id,
          :token => invalid_authy_token,
          :force => true
        ).and_return(verify_failure)

        too_many_failed_attempts.times do
          post :POST_verify_authy, token: invalid_authy_token
        end

        user.reload
        expect(user.access_locked?).to be_truthy
      end

    end

    context 'User is not lockable' do

      it 'does not lock the account when failed_attempts exceeds maximum' do
        request.session['user_id']               = @user.id
        request.session['user_password_checked'] = true

        expect(Authy::API).to receive(:verify).exactly(too_many_failed_attempts).times.with(
          :id => @user.authy_id,
          :token => invalid_authy_token,
          :force => true
        ).and_return(verify_failure)

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
      expect(response).to render_template('enable_authy')
    end

    it "Shouldn't render enable authy view" do
      get :GET_enable_authy
      expect(response).to redirect_to(new_user_session_url)
    end

    it "should redirect if user has authy enabled" do
      @user.update_attribute(:authy_enabled, true)
      sign_in @user
      get :GET_enable_authy
      expect(response).to redirect_to(root_url)
      expect(flash.now[:notice]).to eq("Two factor authentication is already enabled.")
    end

    it "Should render enable authy view if authy enabled is false" do
      sign_in @user
      get :GET_enable_authy
      expect(response).to render_template('enable_authy')
    end
  end

  describe "POST #enable_authy" do
    it "Should create user in authy application" do
      cellphone = '3010008090'
      country_code = '57'
      user2 = create_user
      sign_in user2

      expect(Authy::API).to receive(:register_user).with(
        :email => user2.email,
        :cellphone => cellphone,
        :country_code => country_code
      ).and_return(double("Authy::User", :ok? => true, :id => "123"))

      post :POST_enable_authy, :cellphone => cellphone, :country_code => country_code
      user2.reload
      expect(user2.authy_id).to eq("123")
      expect(flash.now[:notice]).to eq("Two factor authentication was enabled")
      expect(response).to redirect_to(user_verify_authy_installation_url)
    end

    it "Should not create user register user failed" do
      cellphone = '22222'
      country_code = '57'
      user2 = create_user
      sign_in user2

      expect(Authy::API).to receive(:register_user).with(
        :email => user2.email,
        :cellphone => cellphone,
        :country_code => country_code
      ).and_return(double("Authy::User", :ok? => false))

      post :POST_enable_authy, :cellphone => cellphone, :country_code => country_code
      expect(response).to render_template('enable_authy')
      expect(flash[:error]).to eq("Something went wrong while enabling two factor authentication")
    end

    it "Should redirect if user isn't authenticated" do
      post :POST_enable_authy, :cellphone => '3010008090', :country_code => '57'
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe "POST #disable_authy" do
    it "Should disable 2FA" do
      sign_in @user
      @user.update_attribute(:authy_enabled, true)

      request.cookies["remember_device"] = {
        :value => {expires: Time.now.to_i, id: @user.id}.to_json,
        :secure => false,
        :expires => User.authy_remember_device.from_now
      }

      expect(Authy::API).to receive(:delete_user).with(:id => @user.authy_id).and_return(double("Authy::Response", :ok? => true))

      post :POST_disable_authy

      expect(response.cookies["remember_device"]).to be_nil
      @user.reload
      expect(@user.authy_id).to be_nil
      expect(@user.authy_enabled).to be_falsey
      expect(flash.now[:notice]).to eq("Two factor authentication was disabled")
      expect(response).to redirect_to(root_url)
    end

    it "Should not disable 2FA" do
      sign_in @user
      @user.update_attribute(:authy_enabled, true)

      authy_response = double('authy_response')
      allow(authy_response).to receive(:ok?).and_return(false)
      expect(Authy::API).to receive(:delete_user).with(:id => @user.authy_id.to_s).and_return(authy_response)

      post :POST_disable_authy
      @user.reload
      expect(@user.authy_id).not_to be_nil
      expect(@user.authy_enabled).to be_truthy
      expect(flash[:error]).to eq("Something went wrong while disabling two factor authentication")
    end

    it "Should redirect if user isn't authenticated" do
      post :POST_disable_authy
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe "GET #verify_authy_installation" do
    it "Should render the authy installation page" do
      sign_in @user
      get :GET_verify_authy_installation
      expect(response).to render_template('verify_authy_installation')
    end

    it "Should redirect if user isn't authenticated" do
      get :GET_verify_authy_installation
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe "POST #verify_authy_installation" do
    it "Should enable authy for user" do
      token = "000000"
      sign_in @user

      expect(Authy::API).to receive(:verify).with(
        :id => @user.authy_id,
        :token => token,
        :force => true
      ).and_return(double("Authy::Response", :ok? => true))

      post :POST_verify_authy_installation, :token => token
      expect(session["user_authy_token_checked"]).to be_truthy
      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq('Two factor authentication was enabled')

      @user.reload
      expect(@user.authy_enabled).to be_truthy
    end

    it "should not enable authy for user" do
      token = "0007777"
      sign_in @user

      expect(Authy::API).to receive(:verify).with(
        :id => @user.authy_id,
        :token => token,
        :force => true
      ).and_return(double("Authy::Response", :ok? => false))

      post :POST_verify_authy_installation, :token => token
      expect(response).to render_template('verify_authy_installation')
      expect(flash[:error]).to eq('Something went wrong while enabling two factor authentication')
    end

    it "Should redirect if user isn't authenticated" do
      get :GET_verify_authy_installation
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe "POST #request_sms" do
    it "Should send sms if user is logged" do
      sign_in @user

      expect(Authy::API).to receive(:request_sms).with(:id => @user.authy_id, :force => true).and_return(double("Authy::Response", :ok? => true, :message => "Token was sent."))

      post :request_sms
      expect(response.content_type).to eq('application/json')
      body = JSON.parse(response.body)

      expect(body['sent']).to be_truthy
      expect(body['message']).to eq("Token was sent.")
    end

    it "Should not send sms if user couldn't be found" do
      post :request_sms
      expect(response.content_type).to eq('application/json')
      body = JSON.parse(response.body)
      expect(body['sent']).to be_falsey
      expect(body['message']).to eq("User couldn't be found.")
    end
  end

  describe "POST #request_phone_call" do
    it "Should send phone call if user is logged" do
      sign_in @user

      expect(Authy::API).to receive(:request_phone_call).with(:id => @user.authy_id, :force => true).and_return(double("Authy::Response", :ok? => true, :message => 'Call started...'))

      post :request_phone_call
      expect(response.content_type).to eq('application/json')
      body = JSON.parse(response.body)
      expect(body['sent']).to be_truthy
      expect(body['message']).to eq("Call started...")
    end

    it "Shoul not send phone call if user couldn't be found" do
      post :request_phone_call
      expect(response.content_type).to eq('application/json')
      body = JSON.parse(response.body)
      expect(body['sent']).to be_falsey
      expect(body['message']).to eq("User couldn't be found.")
    end
  end

  describe "GET #authy_onetouch_status" do
    # OneTouch stubbed due to test API key not having OneTouch enabled
    before do
      allow(Authy::OneTouch).to receive(:send_approval_request).with(id: @user.authy_id) { { 'approval_request' => { 'uuid' => SecureRandom.uuid } } }
      @uuid = Authy::OneTouch.send_approval_request(id: @user.authy_id)['approval_request']['uuid']
    end

    it "Should return a 202 status code when pending" do
      allow(Authy::API).to receive(:get_request).with(/onetouch\/json\/approval_requests\/.+/) { { 'approval_request' => { 'status' => 'pending' } } }
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
      get :GET_authy_onetouch_status, onetouch_uuid: @uuid
      expect(response.code).to eq("202")
    end

    it "Should return a 401 status code when denied" do
      allow(Authy::API).to receive(:get_request).with(/onetouch\/json\/approval_requests\/.+/) { { 'approval_request' => { 'status' => 'denied' } } }
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
      get :GET_authy_onetouch_status, onetouch_uuid: @uuid
      expect(response.code).to eq("401")
    end

    it "Should return a 200 status code when approved" do
      allow(Authy::API).to receive(:get_request).with(/onetouch\/json\/approval_requests\/.+/) { { 'approval_request' => { 'status' => 'approved' } } }
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
      get :GET_authy_onetouch_status, onetouch_uuid: @uuid
      expect(response.code).to eq("200")
    end

    it "Should render a JSON object with the redirect path when approved" do
      allow(Authy::API).to receive(:get_request).with(/onetouch\/json\/approval_requests\/.+/) { { 'approval_request' => { 'status' => 'approved' } } }
      request.session["user_id"] = @user.id
      request.session["user_password_checked"] = true
      get :GET_authy_onetouch_status, onetouch_uuid: @uuid
      expect(response.body).to eq({ redirect: root_path }.to_json)
    end

    it "Should not render the second step of authentication if first step is incomplete" do
      request.session["user_id"] = @user.id
      get :GET_authy_onetouch_status
      expect(response).to redirect_to(root_url)
    end

    it "should redirect to root_url" do
      get :GET_authy_onetouch_status
      expect(response).to redirect_to(root_url)
    end
  end
end
