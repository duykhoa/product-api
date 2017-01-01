class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.references :product
      t.references :image

      t.timestamps null: false
    end
  end
end
