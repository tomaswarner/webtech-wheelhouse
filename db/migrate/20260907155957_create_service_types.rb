class CreateServiceTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :service_types do |t|
      t.string :name, null: false
      t.decimal :current_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :service_types, :name, unique: true
  end
end