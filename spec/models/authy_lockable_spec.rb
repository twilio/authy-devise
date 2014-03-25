require 'spec_helper'

describe Devise::Models::AuthyLockable do

  context 'model includes Devise::Models::Lockable' do

    let(:user) { create_lockable_user authy_id: '20' }

    context '#lockable?' do

      it 'returns true if lock_strategy is :failed_attempts' do
        expect(user.lockable?).to be_true
      end

      it 'returns false if lock_strategy is anything other than :failed attempts' do
        Devise.lock_strategy = :none
        expect(user.lockable?).to be_false
        Devise.lock_strategy = :failed_attempts
      end

    end

    context '#invalid_authy_attempt!' do

      it 'resets failed_attempts to 0 if nil' do
        user.update_attribute :failed_attempts, nil
        user.invalid_authy_attempt!
        expect(user.failed_attempts).to eq(1)
      end

      it 'respects the maximum attempts configuration for Devise::Models::Lockable' do
        4.times { user.invalid_authy_attempt! }
        expect(user.send :attempts_exceeded?).to be_true # protected method
        expect(user.access_locked?).to be_true
      end

      it 'returns true if the account is locked' do
        3.times { user.invalid_authy_attempt! }
        expect(user.invalid_authy_attempt!).to be_true
      end

      it 'returns false if the account is not locked' do
        expect(user.invalid_authy_attempt!).to be_false
      end

    end

  end

  context 'model does not include Devise::Models::Lockable' do

    let(:user) { create_user authy_id: '20' }

    context '#lockable?' do

      it 'returns false' do
        expect(user.lockable?).to be_false
      end

    end

    context '#invalid_authy_attempt!' do

      it "doesn't affect anything" do
        expect(user.invalid_authy_attempt!).to be_false
        expect(user.failed_attempts).to be_nil
      end

    end

  end

end
