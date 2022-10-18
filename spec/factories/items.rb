FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Commerce.material }
    unit_price { Faker::Number.decimal(l_digits: 2) }
    merchant_id { 1 }
  end
end
