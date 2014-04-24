class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :authy_authenticatable, :authy_lockable, :database_authenticatable,
          :registerable, :recoverable, :rememberable, :trackable,
          :validatable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :authy_id, :last_sign_in_with_authy, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :authy_id, :last_sign_in_with_authy, :title, :body
end
