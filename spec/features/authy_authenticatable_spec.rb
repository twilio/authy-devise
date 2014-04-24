require 'spec_helper'

describe "Authy Autnenticatable", :type => :request do
  describe "If user don't have two factor authentication should login with email - password" do
    before :each do
      @user = create_user(:email => 'foo@bar.com')
    end

    it "Sign in should succeed" do
      fill_sign_in_form('foo@bar.com', '12345678')
      current_path.should == root_path
      page.should have_content('Signed in successfully.')
    end

    it "Sign in shouldn't success" do
      fill_sign_in_form('foo@bar.com', '14567823')
      current_path.should == new_user_session_path
      page.should_not have_content('Signed in successfully.')
    end
  end

  describe "If user have two factor authentication" do
    before :each do
      @user = create_user(:authy_id => 1)
      @user.update_attribute(:authy_enabled, true)
    end

    it "Sign in should succeed" do
      fill_sign_in_form(@user.email, '12345678')
      current_path.should == user_verify_authy_path
      page.should have_content('Please enter your Authy token')

      within('#devise_authy') do
        fill_in 'authy-token', :with => '0000000'
      end
      click_on 'Check Token'
      current_path.should == root_path
      page.should have_content(I18n.t('devise.devise_authy.user.signed_in'))
      @user.reload
      @user.last_sign_in_with_authy.should_not be_nil
    end

    it "Sign in shouldn't succeed" do
      fill_sign_in_form(@user.email, '12345678')
      current_path.should == user_verify_authy_path
      page.should have_content('Please enter your Authy token')

      within('#devise_authy') do
        fill_in 'authy-token', :with => '324567'
      end
      click_on 'Check Token'
      current_path.should == user_verify_authy_path
      @user.reload
      @user.last_sign_in_with_authy.should be_nil
    end

    describe "With cookie['remember_device']" do
      it "Should prompt for a token" do
        cookie_val = sign_cookie("remember_device", Time.now.to_i - 2.month.to_i)
        page.driver.browser.set_cookie("remember_device=#{cookie_val}")
        fill_sign_in_form(@user.email, '12345678')
        current_path.should == user_verify_authy_path
        page.should have_content('Please enter your Authy token')
      end

      it "Shouldn't prompt for a token" do
        cookie_val = sign_cookie("remember_device", Time.now.to_i)
        page.driver.browser.set_cookie("remember_device=#{cookie_val}")
        fill_sign_in_form(@user.email, '12345678')
        current_path.should == root_path
        page.should have_content("Signed in successfully.")
      end
    end

    it "With cookie['current_user_id'] and cookie['user_password_checked']" do
      page.driver.browser.set_cookie("current_user_id=#{@user.id}")
      page.driver.browser.set_cookie('user_password_checked=true')

      visit user_verify_authy_path
      current_path.should == new_user_session_path
      page.should have_content('Sign in')
    end

    it "Click link Request sms" do
      fill_sign_in_form(@user.email, '12345678')
      click_link 'Request SMS'
      page.should have_content("SMS token was sent")
    end
  end
end
