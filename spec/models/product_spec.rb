require 'rails_helper'

describe Product, type: :model do
  describe "supports soft delete" do
    it "update deleted_at" do
      product = create(:product)
      product.destroy
      product.reload

      expect(product.deleted_at).not_to be nil
      expect(Product.count).to eq 0
    end
  end

  describe "has many images" do
    it do
      product = create :product
      image = create(:image, product: product)

      expect{product.images}.not_to raise_error
    end
  end
end
