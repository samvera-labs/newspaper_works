FactoryBot.define do
  factory :ability do
    user
    initialize_with { user }
  end
end
