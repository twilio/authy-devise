# frozen_string_literal: true
require "generators/devise_authy/devise_authy_generator"

RSpec.describe DeviseAuthy::Generators::DeviseAuthyGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)

  after(:all) do
    prepare_destination
  end

  def prepare_app
    FileUtils.mkdir_p(File.join(destination_root, "app", "models"))
    File.open(File.join(destination_root, "app", "models", "user.rb"), "w") do |file|
      file << "class User < ActiveRecord::Base\n" \
              "  devise :database_authenticatable, :registerable,\n" \
              "         :recoverable, :rememberable, :trackable, :validatable\n" \
              "  attr_accessible :email\n" \
              "end"
    end
  end

  before(:all) do
    prepare_destination
    prepare_app
    run_generator ["user"]
  end

  it "adds authy_authenticatable module and authy attributes" do
    expect(destination_root).to have_structure {
      directory "app" do
        directory "models" do
          file "user.rb" do
            contains "devise :authy_authenticatable"
            contains "attr_accessible :authy_id, :last_sign_in_with_authy, :email"
          end
        end
      end
    }
  end

end