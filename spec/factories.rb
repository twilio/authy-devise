# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end
end

FactoryBot.define do
  factory :user do
    email { generate(:email) }
    password { "correct horse battery staple" }
  end
end