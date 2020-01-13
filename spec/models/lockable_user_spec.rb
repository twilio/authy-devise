# frozen_string_literal: true

RSpec.describe LockableUser, type: :model do
  describe "with a user with an authy id" do
    let(:user) { create(:lockable_user, :authy_id => '20') }

    describe "#lockable?" do
      it "is true if lock_strategy is :failed_attempts" do
        old_lock_strategy = Devise.lock_strategy
        Devise.lock_strategy = :failed_attempts
        expect(user.lockable?).to be true
        Devise.lock_strategy = old_lock_strategy
      end

      it "is false if lock_strategy is anything other than :failed_attempts" do
        old_lock_strategy = Devise.lock_strategy
        Devise.lock_strategy = :none
        expect(user.lockable?).to be false
        Devise.lock_strategy = old_lock_strategy
      end
    end
  end

end