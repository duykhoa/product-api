class RemoveProductIdFromImages < ActiveRecord::Migration
  def up
    remove_column :images, :product_id
  end

  def down
    add_column :images, :product_id, :integer
  end
end
