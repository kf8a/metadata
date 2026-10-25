# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email
    password { 'a-long-test-password' }

    factory :email_confirmed_user do
      email_confirmed { true }

      factory :admin_user do
        role  { 'admin' }
      end
    end
  end
end
