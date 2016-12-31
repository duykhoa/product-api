class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.float :price
      t.string :name
      t.text :description
      t.timestamps null: false
    end

    add_index :products, :id
    add_index :products, :name
  end
end
