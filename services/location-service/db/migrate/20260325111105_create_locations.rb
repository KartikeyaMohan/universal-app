class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.bigint :user_id, null: false
      t.decimal :latitude, precision: 8, scale: 5, null: false
      t.decimal :longitude, precision: 8, scale: 5, null: false
      t.decimal :accuracy, precision: 4, scale: 2, null: true
      
      t.timestamps
    end
  end
end
