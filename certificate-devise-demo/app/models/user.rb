class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :certificate_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :certificate_id, :last_sign_in_with_certificate, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :certificate_id, :last_sign_in_with_certificate, :title, :body
end
