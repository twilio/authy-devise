require 'spec_helper'

describe "Certificate Authenticatable", :type => :request do
  describe "If user don't have two factor authentication should login with email - password" do
    before :each do
      @user = create_user(:email => 'foo@bar.com')
    end

    it "Sign in should succeed" do
			pending
    end

    it "Sign in shouldn't success" do
			pending
    end
  end
end
