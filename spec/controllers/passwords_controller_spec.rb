# frozen_string_literal: true

RSpec.describe DeviseAuthy::PasswordsController, type: :controller do
  before(:each) { request.env["devise.mapping"] = Devise.mappings[:user] }

  describe "during Devise :recoverable flow reset password stage" do
    describe "with a user without authy id" do
      let(:user) { create(:user) }

      it "should sign in the user after password reset" do
        token = user.send_reset_password_instructions
        put :update, :params => { :user => {
          :reset_password_token => token,
          :password => "password",
          :password_confirmation => "password"
        }}
        expect(subject.current_user).to eq(user)
      end
    end

    describe "with a user with authy id and authy enabled" do
      let(:user) { create(:authy_user) }

      it "should not sign in the user after password reset" do
        token = user.send_reset_password_instructions
        put :update, :params => { :user => {
          :reset_password_token => token,
          :password => "password",
          :password_confirmation => "password"
        }}
        expect(subject.current_user).to be nil
      end
    end
  end
end