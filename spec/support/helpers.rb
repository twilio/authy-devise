def generate_unique_email
  @@email_count ||= 0
  @@email_count += 1
  "test#{@@email_count}@example.com"
end

def valid_attributes(attributes={})
  { :email => generate_unique_email,
    :password => '12345678',
    :password_confirmation => '12345678' }.update(attributes)
end

def new_user(attributes={})
  User.new(valid_attributes(attributes))
end

def create_user(attributes={})
  User.create!(valid_attributes(attributes))
end

def create_lockable_user(attributes={})
  LockableUser.create!(valid_attributes(attributes))
end

def fill_sign_in_form(email, password, form_selector = nil, sign_in_path = nil)
  form_selector ||= '#new_user'
  sign_in_path  ||= new_user_session_path
  visit sign_in_path
  within(form_selector) do
    fill_in 'Email', :with => email
    fill_in 'Password', :with => password
  end
  click_on 'Sign in'
end

def fill_verify_token_form(token)
  within('#devise_authy') { fill_in 'authy-token', with: token }
  click_on 'Check Token'
end

def sign_cookie(name, val)
  verifier = ActiveSupport::MessageVerifier.new(RailsApp::Application.config.secret_token)
  verifier.generate(val)
end

def too_many_failed_attempts
  Devise.maximum_attempts + 1
end

def valid_authy_token
  '0000000'
end

def invalid_authy_token
  '999999'
end

def lock_user_account
  too_many_failed_attempts.times { fill_verify_token_form invalid_authy_token }
end
