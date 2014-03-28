require 'spec_helper'

feature 'Authy Lockable' do

  context 'during verify code when Authy enabled' do

    let(:user) do
      u = create_lockable_user authy_id: 20, email: 'foo@bar.com'
      u.update_attribute :authy_enabled, true
      u
    end

    before :each do
      fill_sign_in_form user.email, '12345678', '#new_lockable_user', new_lockable_user_session_path
    end

    scenario 'account locked when user enters invalid code too many times' do
      Devise.maximum_attempts.times do |i|
        fill_verify_token_form invalid_authy_token
        assert_at lockable_user_verify_authy_path
        expect(page).to have_content('Please enter your Authy token')
        user.reload
        assert_account_locked_for user, nil
        expect(user.failed_attempts).to eq(i + 1)
      end

      fill_verify_token_form invalid_authy_token
      user.reload
      assert_at new_user_session_path
      assert_account_locked_for user
      visit root_path
      assert_at new_user_session_path
    end

  end

  context 'during verify Authy installation' do

    let(:user) { create_lockable_user email: 'foo@bar.com' }

    before do
      fill_sign_in_form user.email, '12345678', '#new_lockable_user', new_lockable_user_session_path
    end

    scenario 'account locked when user enters invalid code too many times' do
      visit lockable_user_enable_authy_path
      fill_in 'authy-countries', with: '1'
      fill_in 'authy-cellphone', with: '8001234567'
      click_on 'Enable'

      Devise.maximum_attempts.times do |i|
        fill_in_verify_authy_installation_form invalid_authy_token
        assert_at lockable_user_verify_authy_installation_path
        expect(page).to have_content('Verify your account')
        user.reload
        assert_account_locked_for user, nil
        expect(user.failed_attempts).to eq(i + 1)
      end

      fill_in_verify_authy_installation_form invalid_authy_token
      user.reload
      assert_at new_user_session_path
      assert_account_locked_for user
      visit root_path
      assert_at new_user_session_path
    end

  end

end
