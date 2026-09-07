class CreateRepairLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :repair_line_items do |t|
      t.bigint :repair_id, null: false
      t.bigint :service_type_id, null: false
      t.decimal :price_charged, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end