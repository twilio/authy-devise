# frozen_string_literal: true

RSpec.describe Devise::DeviseAuthyController, type: :controller do
  let(:user) { create(:authy_user) }
  before(:each) { request.env["devise.mapping"] = Devise.mappings[:user] }

  describe "first step of authentication not complete" do
    describe "with no user details in the session" do
      describe "#GET_verify_authy" do
        it "should redirect to the root_path" do
          get :GET_verify_authy
          expect(response).to redirect_to(root_path)
        end

        it "should not make a OneTouch request" do
          expect(Authy::OneTouch).not_to receive(:send_approval_request)
          get :GET_verify_authy
        end
      end

      describe "#POST_verify_authy" do
        it "should redirect to the root_path" do
          post :POST_verify_authy
          expect(response).to redirect_to(root_path)
        end

        it "should not verify a token" do
          expect(Authy::API).not_to receive(:verify)
          post :POST_verify_authy
        end
      end

      describe "#GET_authy_onetouch_status" do
        xit "should redirect to the root_path" do
          get :GET_authy_onetouch_status
          expect(response).to redirect_to(root_path)
        end

        xit "should not request the one touch status" do
          expect(Authy::API).not_to receive(:get_request)
          get :GET_authy_onetouch_status
        end
      end
    end

    describe "without checking the password" do
      before(:each) { request.session["user_id"] = user.id }

      describe "#GET_verify_authy" do
        it "should redirect to the root_path" do
          get :GET_verify_authy
          expect(response).to redirect_to(root_path)
        end

        it "should not make a OneTouch request" do
          expect(Authy::OneTouch).not_to receive(:send_approval_request)
          get :GET_verify_authy
        end
      end

      describe "#POST_verify_authy" do
        it "should redirect to the root_path" do
          post :POST_verify_authy
          expect(response).to redirect_to(root_path)
        end

        it "should not verify a token" do
          expect(Authy::API).not_to receive(:verify)
          post :POST_verify_authy
        end
      end

      describe "#GET_authy_onetouch_status" do
        xit "should redirect to the root_path" do
          get :GET_authy_onetouch_status
          expect(response).to redirect_to(root_path)
        end

        xit "should not request the one touch status" do
          expect(Authy::API).not_to receive(:get_request)
          get :GET_authy_onetouch_status
        end
      end
    end
  end

  describe "when the first step of authentication is complete" do
    before do
      request.session["user_id"] = user.id
      request.session["user_password_checked"] = true
    end

    describe "GET #verify_authy" do
      it "Should render the second step of authentication" do
        get :GET_verify_authy
        expect(response).to render_template('verify_authy')
      end

      it "should not make a OneTouch request" do
        expect(Authy::OneTouch).not_to receive(:send_approval_request)
        get :GET_verify_authy
      end

      describe "when OneTouch is enabled" do
        before(:each) do
          Devise.authy_enable_onetouch = true
        end

        after(:each) do
          Devise.authy_enable_onetouch = false
        end

        it "should make a OneTouch request and assign the uuid" do
          expect(Authy::OneTouch).to receive(:send_approval_request)
                                 .with(id: user.authy_id, message: 'Request to Login')
                                 .and_return('approval_request' => { 'uuid' => 'uuid' }).once
          get :GET_verify_authy
          expect(assigns[:onetouch_uuid]).to eq('uuid')
        end
      end
    end

    describe "POST #verify_authy" do
      let(:verify_success) { double("Authy::Response", :ok? => true) }
      let(:verify_failure) { double("Authy::Response", :ok? => false) }
      let(:valid_authy_token) { rand(0..999999).to_s.rjust(6, '0') }
      let(:invalid_authy_token) { rand(0..999999).to_s.rjust(6, '0') }

      describe "with a valid token" do
        before(:each) {
          expect(Authy::API).to receive(:verify).with(
            :id => user.authy_id,
            :token => valid_authy_token,
            :force => true
          ).and_return(verify_success)
        }

        describe "without remembering" do
          before(:each) {
            post :POST_verify_authy, params: { :token => valid_authy_token }
          }

          it "should log the user in" do
            expect(subject.current_user).to eq(user)
            expect(session["user_authy_token_checked"]).to be_truthy
          end

          it "should set the last_sign_in_with_authy field on the user" do
            expect(user.last_sign_in_with_authy).to be_nil
            user.reload
            expect(user.last_sign_in_with_authy).not_to be_nil
          end

          it "should not remember the user" do
            expect(cookies["remember_device"]).to be_nil
          end

          it "should redirect to the root_path and set a flash notice" do
            expect(response).to redirect_to(root_path)
            expect(flash[:notice]).not_to be_nil
            expect(flash[:error]).to be nil
          end

          it "should not set a remember_device cookie" do
            cookie = cookies["remember_device"]
            expect(cookie).to be_nil
          end

          it "should not remember the user" do
            user.reload
            expect(user.remember_created_at).to be nil
          end
        end

        describe "and remember device selected" do
          before(:each) {
            post :POST_verify_authy, params: {
              :token => valid_authy_token,
              :remember_device => '1'
            }
          }

          it "should set a signed remember_device cookie" do
            jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
            cookie = jar.signed["remember_device"]
            expect(cookie).not_to be_nil
            parsed_cookie = JSON.parse(cookie)
            expect(parsed_cookie["id"]).to eq(user.id)
          end
        end

        describe "and remember_me in the session" do
          before(:each) do
            request.session["user_remember_me"] = true
            post :POST_verify_authy, params: { :token => valid_authy_token }
          end

          it "should remember the user" do
            user.reload
            expect(user.remember_created_at).to be_within(1).of(Time.zone.now)
          end
        end
      end

      describe "with an invalid token" do
        before(:each) {
          expect(Authy::API).to receive(:verify).with(
            :id => user.authy_id,
            :token => invalid_authy_token,
            :force => true
          ).and_return(verify_failure)
          post :POST_verify_authy, params: { :token => invalid_authy_token }
        }

        it "Shouldn't log the user in" do
          expect(subject.current_user).to be nil
        end

        it "should redirect to the verification page" do
          expect(response).to render_template('verify_authy')
        end

        it "should set an error message in the flash" do
          expect(flash[:notice]).to be nil
          expect(flash[:error]).not_to be nil
        end
      end

      describe 'with a lockable user' do
        let(:lockable_user) { create(:lockable_authy_user) }
        before(:all) { Devise.lock_strategy = :failed_attempts }

        before(:each) do
          request.session["user_id"] = lockable_user.id
          request.session["user_password_checked"] = true
        end

        it 'locks the account when failed_attempts exceeds maximum' do
          expect(Authy::API).to receive(:verify).exactly(Devise.maximum_attempts).times.with(
            :id => lockable_user.authy_id,
            :token => invalid_authy_token,
            :force => true
          ).and_return(verify_failure)
          (Devise.maximum_attempts).times do
            post :POST_verify_authy, params: { token: invalid_authy_token }
          end

          lockable_user.reload
          expect(lockable_user.access_locked?).to be_truthy
        end

      end

      context 'User is not lockable' do

        it 'does not lock the account when failed_attempts exceeds maximum' do
          request.session['user_id']               = user.id
          request.session['user_password_checked'] = true

          expect(Authy::API).to receive(:verify).exactly(Devise.maximum_attempts).times.with(
            :id => user.authy_id,
            :token => invalid_authy_token,
            :force => true
          ).and_return(verify_failure)

          Devise.maximum_attempts.times do
            post :POST_verify_authy, params: { token: invalid_authy_token }
          end

          user.reload
          expect(user.locked_at).to be_nil
        end

      end

    end
  end
end