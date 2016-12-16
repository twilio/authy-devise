require 'spec_helper'

describe Devise::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:user){ create_user(password: "12345678") }

  describe "POST #create" do
    context "without 2fa enabled" do
      it "Logs in user without redirecting to verify authy page" do
        post :create, user: { email: user.email, password: "12345678"  }
        expect(flash.now[:notice]).to eq("Signed in successfully.")
        expect(response).to redirect_to(root_url)

        expect(controller.current_user).to eq(user)
        
        # Visiting the new session page flashes "already signed in" message
        get :new
        expect(flash.now[:alert]).to eq("You are already signed in.")
      end
    end

    context "with 2fa enabled" do
      let(:user){ create_user(authy_id: 2, password: "12345678", authy_enabled: true) }

      it "Does not login user and does not set a current_user" do
        post :create, user: { email: user.email, password: "12345678"  }
        expect(response).to redirect_to(user_verify_authy_path)

        expect(controller.current_user).to eq(nil)

        # Visiting the new session page, does not flash the "already signed in" message
        get :new
        expect(flash.now[:alert]).to_not eq("You are already signed in.")
        expect(response).to_not redirect_to(root_url)
      end
    end
  end
end
