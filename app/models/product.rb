class Product < ActiveRecord::Base
  acts_as_paranoid
  has_many :images
end
