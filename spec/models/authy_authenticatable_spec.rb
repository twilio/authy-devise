require 'spec_helper'

describe Devise::Models::AuthyAuthenticatable, type: :model do
  before(:each) do
    @user = create_user(:authy_id => '20')
  end

  describe "User#find_by_authy_id" do
    it "Should find the user" do
      expect(User.find_by_authy_id('20')).not_to be_nil
    end

    it "Shouldn't find the user" do
      expect(User.find_by_authy_id('80')).to be_nil
    end
  end
end
