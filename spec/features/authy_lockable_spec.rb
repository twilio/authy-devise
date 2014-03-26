require 'spec_helper'

describe 'Authy Lockable' do

  let(:user) do
    u = create_lockable_user authy_id: 20, email: 'foo@bar.com'
    u.update_attribute :authy_enabled, true
    u
  end

  before :each do
    fill_sign_in_form user.email, '12345678', '#new_lockable_user', new_lockable_user_session_path
  end

  context 'user enters incorrect code' do

    context 'maximum failed attempts not exceeded' do

      it 'renders verify_authy view' do
        fill_verify_token_form invalid_authy_token
        expect(current_path).to eq(lockable_user_verify_authy_path)
        expect(page).to have_content('Please enter your Authy token')
      end

      it 'does not lock out the user' do
        fill_verify_token_form invalid_authy_token
        user.reload
        expect(user.access_locked?).to be_false
      end

      it 'updates fail_attempts' do
        fill_verify_token_form invalid_authy_token
        user.reload
        expect(user.failed_attempts).to eq(1)
      end

    end

    context 'max failed attempts exceeded' do

      it 'locks the account' do
        lock_user_account
        user.reload
        expect(user.locked_at).not_to be_nil
      end

      it 'signs the user out' do
        lock_user_account
        visit root_path
        expect(current_path).to eq(new_user_session_path)
      end

      it 'redirects to after_sign_out_path' do
        lock_user_account
        expect(current_path).to eq(new_user_session_path)
      end

    end

  end

  context 'user enters correct code' do

    it 'redirects' do
      fill_verify_token_form valid_authy_token
      expect(current_path).not_to eq(lockable_user_verify_authy_path)
    end

    it 'does not lock the account' do
      fill_verify_token_form valid_authy_token
      user.reload
      expect(user.access_locked?).to be_false
    end

    it 'does not modify failed_attempts' do
      fill_verify_token_form valid_authy_token
      user.reload
      expect(user.failed_attempts).to eq(0)
    end

  end

end
