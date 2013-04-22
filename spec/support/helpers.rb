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

def fill_sign_in_form(email, password)
  visit new_user_session_path
  within("#new_user") do
    fill_in 'Email', :with => email
    fill_in 'Password', :with => password
  end
  click_on 'Sign in'
end

def sign_cookie(name, val)
   verifier = ActiveSupport::MessageVerifier.new(RailsApp::Application.config.secret_token)
   verifier.generate(val)
 end