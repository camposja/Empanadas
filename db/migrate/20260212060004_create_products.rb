class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.boolean :featured, default: false, null: false
      t.boolean :seasonal, default: false, null: false
      t.boolean :active, default: true, null: false
      t.references :collection, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :slug, unique: true
  end
end
