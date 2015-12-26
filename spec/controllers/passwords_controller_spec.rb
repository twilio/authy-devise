require 'spec_helper'

describe DeviseAuthy::PasswordsController do
  include Devise::TestHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "when the user has authy enabled" do

    describe "Reset password" do
      it "Should redirect to verify token view" do
        user = create_user(:authy_id => 1)
        user.reset_password_token = User.reset_password_token
        user.reset_password_sent_at = Time.now.utc
        user.authy_enabled = true
        user.save

        put :update, :user => { :reset_password_token => user.reset_password_token, :password => "password", :password_confirmation => "password" }

        user.reload
        expect(user.last_sign_in_at).to be_nil
        expect(response).to redirect_to(root_url)
      end
    end
  end

  context "when the user don't have 2FA" do
    describe "Reset password" do
      it "Should sign in the user" do
        user = create_user
        user.reset_password_token = User.reset_password_token
        user.reset_password_sent_at = Time.now.utc
        user.save

        last_sign_in_at = user.last_sign_in_at

        put :update, :user => { :reset_password_token => user.reset_password_token, :password => "password", :password_confirmation => "password" }
        expect(response).to redirect_to(root_url)

        user.reload
        expect(user.last_sign_in_at).not_to be_nil
        expect(flash[:notice]).to eq("Your password was changed successfully. You are now signed in.")
      end
    end
  end
end