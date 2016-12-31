class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.float :price
      t.string :name
      t.text :description
      t.timestamps null: false
    end
  end
end
