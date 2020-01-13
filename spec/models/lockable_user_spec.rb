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

    describe "#invalid_authy_attempt!" do
      before(:all) {
        @old_lock_strategy = Devise.lock_strategy
        Devise.lock_strategy = :failed_attempts
      }
      after(:all) {
        Devise.lock_strategy = @old_lock_strategy
      }

      it "if failed_attempts is nil it treats it as though it was 0" do
        user.update_attribute(:failed_attempts, nil)
        user.invalid_authy_attempt!
        expect(user.failed_attempts).to be 1
      end

      it 'updates failed_attempts once per attempt' do
        10.times { user.invalid_authy_attempt! }
        expect(user.failed_attempts).to eq(10)
      end

      it 'respects the maximum attempts configuration for Devise::Models::Lockable' do
        Devise.maximum_attempts = 3
        2.times { user.invalid_authy_attempt! }
        expect(user.send(:attempts_exceeded?)).to be false # protected method
        user.invalid_authy_attempt!
        expect(user.send(:attempts_exceeded?)).to be true
        expect(user.access_locked?).to be true
      end

      it "returns false until the account is locked" do
        Devise.maximum_attempts = 3
        2.times { expect(user.invalid_authy_attempt!).to be false }
        expect(user.invalid_authy_attempt!).to be true
      end

    end

  end

end