# Steps to re-create this demo

1. Create a new rails application:  

        rails new authy-devise-demo
        rm public/index.html

2. Add dependencies to Gemfile:

        gem 'devise', '2.1.3'
        gem 'devise-authy'

3. Create a root controller

        rails g controller Welcome index

4. Edit `config/routes.rb` and uncomment:

        root :to => 'welcome#index'

5. Create `config/initializers/authy.rb` and add:

        Authy.api_key = '<your-api-key>'

6. Install and configure Devise and Devise Authy

        rails g devise:install
        rails g devise User
        rails g devise_authy:install
        rails g devise_authy User

7. Create a user

	    rake db:migrate
		rails runner 'User.create(:email => "user@example.com", :password => "password", :password_confirmation => "password")'


8. Edit `app/controllers/welcome_controller.rb` and add:

	    before_filter :authenticate_user!


9. Edit `app/views/welcome/index.html.erb` and add:

	    <%= link_to "Enable authy", user_enable_authy_path %>
	    <%= link_to "Logout", destroy_user_session_path, :method => :delete %>


10. Done 


# Steps to use this demo

1. Clone the repository

		git clone git://github.com/authy/authy-devise-demo.git

2. Create a user

	    rake db:migrate
		rails runner 'User.create(:email => "user@example.com", :password => "password", :password_confirmation => "password")'

3. Done

