require 'spec_helper'

describe Devise::Models::AuthyAuthenticatable do
  before(:each) do
    @user = User.create(:email => 'joha@senekis.co', :authy_id => '20')
  end

  describe "User#find_by_authy_id" do
    it "Should find the user" do
      User.find_by_authy_id('20').should_not nil
    end

    it "Shouldn't find the user" do
      User.find_by_authy_id('80').should be_nil
    end
  end
end
