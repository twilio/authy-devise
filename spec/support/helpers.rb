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