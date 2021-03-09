FactoryBot.define do
  factory :task do
    association :user
    sequence(:name) { |n| "プログラミング#{n}" }
    date { Date.new(2021, 3, 1) }
    amount { 5.5 }
  end
end

