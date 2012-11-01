require 'spec_helper'

describe Devise::DeviseAuthyController do
  include Devise::TestHelpers

  before(:each) do
    @user = User.create(:email => 'joha@senekis.co', :authy_id => '80', :password => 'sorting7')
  end

  describe "GET #show" do
    it "Should render the second step of authentication" do
      request.env["devise.mapping"] = Devise.mappings[:user]
      get :show
      response.should render_template('show')
    end
  end

  describe "PUT #update" do
    it "Should login the user if token is ok" do
      request.env["devise.mapping"] = Devise.mappings[:user]
      response = mock("authy_request", body: {'status' => 'ok'}.to_json)
      response.stub(:ok?).and_return(true)
      Authy::API.should_receive(:verify).with(:id => '80', :token => '567890').and_return(response)

      put :update, :user => {
        :authy_id => '80',
        :token => '567890'
      }
      response.should redirect_to(root_url)
      flash.now[:notice].should_not be_nil
    end

    it "Shouldn't login the user if token is invalid" do
      request.env["devise.mapping"] = Devise.mappings[:user]
      response = mock("authy_request", body: {"errors"=>{"token"=>"is invalid"}}.to_json)
      response.stub(:ok?).and_return(false)
      Authy::API.should_receive(:verify).with(:id => '80', :token => '567890').and_return(response)
      put :update, :user => {
        :authy_id => '80',
        :token => '567890'
      }
      response.should redirect_to(root_url)
    end
  end

  describe "GET #register" do
    it "Should render enable authy view" do
      sign_in @user
      request.env["devise.mapping"] = Devise.mappings[:user]
      get :register
      response.should render_template('register')
    end

    it "Shouldn't render enable authy view" do
      request.env["devise.mapping"] = Devise.mappings[:user]
      get :register
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "POST #create" do
    it "Should create user in authy application" do
      request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in @user
      response = mock("authy_request", body: {'success' => 'ok'}.to_json)
      response.should_receive(:ok?).and_return(true)
      response.should_receive(:id).and_return('99')
      Authy::API.should_receive(:register_user).with(:email => @user.email, :cellphone => '3010008090', :country_code => '57').and_return(response)

      post :create, :cellphone => '3010008090', :country_code => '57'

      flash.now[:notice].should_not be_nil
      response.should redirect_to(root_url)
    end

    it "Should redirect if user isn't authenticated" do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, :user => {
        :cellphone => '3010008090',
        :country_code => '57'
      }
      response.should redirect_to(new_user_session_url)
    end
  end
end