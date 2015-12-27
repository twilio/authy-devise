require 'spec_helper'

describe Devise::Models::AuthyLockable, type: :controller do

  context 'model includes Devise::Models::Lockable' do

    let(:user) { create_lockable_user authy_id: '20' }

    context '#lockable?' do

      it 'returns true if lock_strategy is :failed_attempts' do
        expect(user.lockable?).to be_truthy
      end

      it 'returns false if lock_strategy is anything other than :failed attempts' do
        Devise.lock_strategy = :none
        expect(user.lockable?).to be_falsey
        Devise.lock_strategy = :failed_attempts
      end

    end

    context '#invalid_authy_attempt!' do

      it 'resets failed_attempts to 0 if nil' do
        user.update_attribute :failed_attempts, nil
        user.invalid_authy_attempt!
        expect(user.failed_attempts).to eq(1)
      end

      it 'updates failed_attempts' do
        10.times { user.invalid_authy_attempt! }
        expect(user.failed_attempts).to eq(10)
      end

      it 'respects the maximum attempts configuration for Devise::Models::Lockable' do
        4.times { user.invalid_authy_attempt! }
        expect(user.send :attempts_exceeded?).to be_truthy # protected method
        expect(user.access_locked?).to be_truthy
      end

      it 'returns true if the account is locked' do
        3.times { user.invalid_authy_attempt! }
        expect(user.invalid_authy_attempt!).to be_truthy
      end

      it 'returns false if the account is not locked' do
        expect(user.invalid_authy_attempt!).to be_falsey
      end

    end

  end

  context 'model misconfigured, includes AuthyLockable w/out Lockable' do

    let(:user) do
      u = create_user authy_id: '20'
      u.extend Devise::Models::AuthyLockable
      u
    end

    context '#lockable?' do

      it 'raises an error' do
        expect { user.lockable? }.to raise_error 'Devise lockable extension required'
      end

    end

    context '#invalid_authy_attempt!' do

      it 'raises an error' do
        expect { user.invalid_authy_attempt! }.to raise_error 'Devise lockable extension required'
      end

    end

  end

end
