class Product < ActiveRecord::Base
  acts_as_paranoid

  has_many :product_images
  has_many :images, through: :product_images

  accepts_nested_attributes_for :product_images

  validates_presence_of :name, :price
end
