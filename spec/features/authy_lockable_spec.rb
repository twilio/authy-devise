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
      expect(Authy::API).to receive(:verify).with(
        :id => user.authy_id,
        :token => invalid_authy_token,
        :force => true
      ).exactly(LockableUser.maximum_attempts).times.and_return(double("Authy::Response", :ok? => false))
      (LockableUser.maximum_attempts - 1).times do |i|
        fill_verify_token_form invalid_authy_token
        assert_at lockable_user_verify_authy_path
        expect(page).to have_content('Please enter your Authy token')
        user.reload
        assert_account_locked_for user, false
        expect(user.failed_attempts).to eq(i + 1)
      end

      fill_verify_token_form invalid_authy_token
      user.reload
      assert_at new_user_session_path
      assert_account_locked_for user, true
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
      country_code = '1'
      cellphone = '8001234567'
      expect(Authy::API).to receive(:register_user).with(
        :email => user.email,
        :cellphone => cellphone,
        :country_code => country_code
      ).and_return(double("Authy::User", :ok? => true, :id => '3'))
      visit lockable_user_enable_authy_path
      fill_in 'authy-countries', with: country_code
      fill_in 'authy-cellphone', with: cellphone
      click_on 'Enable'

      expect(Authy::API).to receive(:verify).with(
        :id => '3',
        :token => invalid_authy_token,
        :force => true
      ).exactly(LockableUser.maximum_attempts).and_return(double("Authy::Response", :ok? => false))
      (LockableUser.maximum_attempts - 1).times do |i|
        fill_in_verify_authy_installation_form invalid_authy_token
        assert_at lockable_user_verify_authy_installation_path
        expect(page).to have_content('Verify your account')
        user.reload
        assert_account_locked_for user, false
        expect(user.failed_attempts).to eq(i + 1)
      end

      fill_in_verify_authy_installation_form invalid_authy_token
      user.reload
      assert_at new_user_session_path
      assert_account_locked_for user, true
      visit root_path
      assert_at new_user_session_path
    end

  end

end
