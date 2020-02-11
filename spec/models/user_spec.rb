# frozen_string_literal: true

RSpec.describe User, type: :model do
  describe "with a user with an authy id" do
    let!(:user) { create(:authy_user) }

    describe "User#find_by_authy_id" do
      it "should find the user" do
        expect(User.first).not_to be nil
        expect(User.find_by_authy_id(user.authy_id)).to eq(user)
      end

      it "shouldn't find the user with the wrong id" do
        expect(User.find_by_authy_id('21')).to be nil
      end
    end

    describe "user#with_authy_authentication?" do
      it "should be false when authy isn't enabled" do
        user.authy_enabled = false
        request = double("request")
        expect(user.with_authy_authentication?(request)).to be false
      end
      it "should be true when authy is enabled" do
        user.authy_enabled = true
        request = double("request")
        expect(user.with_authy_authentication?(request)).to be true
      end
    end

  end
  describe "with a user without an authy id" do
    let!(:user) { create(:user) }

    describe "user#with_authy_authentication?" do
      it "should be false regardless of authy_enabled field" do
        request = double("request")
        expect(user.with_authy_authentication?(request)).to be false
        user.authy_enabled = true
        expect(user.with_authy_authentication?(request)).to be false
      end
    end
  end
end