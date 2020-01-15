# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :authy_id do |n|
    n.to_s
  end

  factory :user do
    email { generate(:email) }
    password { "correct horse battery staple" }

    factory :authy_user do
      authy_id { generate(:authy_id) }
      authy_enabled { true }
    end
  end

  factory :lockable_user, class: LockableUser do
    email { generate(:email) }
    password { "correct horse battery staple" }
  end

  factory :lockable_authy_user, class: LockableUser do
    email { generate(:email) }
    password { "correct horse battery staple" }
    authy_id { generate(:authy_id) }
    authy_enabled { true }
  end
end