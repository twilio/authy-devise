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

  describe "If user have two factor authentication should login with email, password and authy token" do
    before :each do
      @user = create_user(:authy_id => '90')
    end

    it "Sign in should succeed" do
      authy_response = mock('authy_response', :ok? => true)
      Authy::API.should_receive(:verify).with(:id => '90', :token => '324567').and_return(authy_response)

      visit new_user_session_path
      fill_sign_in_form(@user.email, '12345678')
      current_path.should == user_devise_authy_path
      page.should have_content('Please enter your Authy token')

      within('#devise_authy') do
        fill_in 'authy-token', :with => '324567'
      end
      click_on 'Check Token'
      current_path.should == root_path
      page.should have_content(I18n.t('devise.devise_authy.user.signed_in'))
    end

    it "Sign in shouldn't success" do
      authy_response = mock('authy_response', :ok? => false)
      Authy::API.should_receive(:verify).with(:id => '90', :token => '324567').and_return(authy_response)

      visit new_user_session_path
      fill_sign_in_form(@user.email, '12345678')
      current_path.should == user_devise_authy_path
      page.should have_content('Please enter your Authy token')

      within('#devise_authy') do
        fill_in 'authy-token', :with => '324567'
      end
      click_on 'Check Token'
      current_path.should == new_user_session_path
    end
  end
end