# frozen_string_literal: true

RSpec.describe DeviseAuthy::Views::Helpers, type: :helper do
  describe "request phone call link" do
    it "produces an anchor to the request-phone-call endpoint" do
      link = helper.authy_request_phone_call_link
      expect(link).to match(%r|href="/users/request-phone-call"|)
      expect(link).to match(%r|data-method="post"|)
      expect(link).to match(%r|data-remote="true"|)
      expect(link).to match(%r|id="authy-request-phone-call-link"|)
      expect(link).to match(%r|>Request phone call<|)
    end

    it "has customisable text" do
      link = helper.authy_request_phone_call_link(title: "Make it ring!")
      expect(link).to match(%r|>Make it ring!<|)
    end
  end

  describe "request sms link" do
    it "produces an anchor to the request-sms endpoint" do
      link = helper.authy_request_sms_link
      expect(link).to match(%r|href="/users/request-sms"|)
      expect(link).to match(%r|data-method="post"|)
      expect(link).to match(%r|data-remote="true"|)
      expect(link).to match(%r|id="authy-request-sms-link"|)
      expect(link).to match(%r|>Request SMS<|)
    end

    it "has customisable text" do
      link = helper.authy_request_phone_call_link(title: "Send a message!")
      expect(link).to match(%r|>Send a message!<|)
    end
  end

  describe "with a user" do
    let(:user) { create(:user) }

    describe "verify_authy_form" do
      it "creates a verify form with the user id as a field" do
        assign(:resource, user)
        form = helper.verify_authy_form { "I'm in a form" }
        expect(form).to match(%r|action="/users/verify_authy"|)
        expect(form).to match(%|<input type="hidden" name="user_id" id="user_id" value="#{user.id}"|)
      end
    end

    describe "enable_authy_form" do
      it "creates a verify form with the user id as a field" do
        assign(:resource, user)
        form = helper.enable_authy_form { "I'm in a form" }
        expect(form).to match(%r|action="/users/enable_authy"|)
      end
    end

    describe "verify_authy_installation_form" do
      it "creates a verify form with the user id as a field" do
        assign(:resource, user)
        form = helper.verify_authy_installation_form { "I'm in a form" }
        expect(form).to match(%r|action="/users/verify_authy_installation"|)
      end
    end

  end
end