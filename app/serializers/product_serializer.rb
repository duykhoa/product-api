class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price
  has_many :images
end
