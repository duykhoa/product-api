FactoryGirl.define do
  factory :product do
    sequence(:name) { |i| "Product Name #{i}"}
    description  "Product description"
    price 10
  end
end
