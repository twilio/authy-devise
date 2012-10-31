require 'spec_helper'

describe Devise::Models::AuthyAuthenticatable do
  before(:each) do
    @user = User.create(:email => 'joha@senekis.co', :authy_id => '20')
  end

  describe "#with_authy_authentication?" do
    it "should return false when user haven't authy_id" do
      # @user.with_authy_authentication?(response).should_be false
    end
  end

  describe "User#find_by_authy_id" do
    it "Should find the user" do
      User.find_by_authy_id('20').should_not be_nil
    end

    it "Shouldn't find the user" do
      User.find_by_authy_id('80').should be_nil
    end
  end
end
