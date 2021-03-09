FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "example#{n}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    password { "password1" }
    password_confirmation { "password1" }
    activated { true }
  end
end
