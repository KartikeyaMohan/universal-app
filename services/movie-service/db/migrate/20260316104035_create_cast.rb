class CreateCast < ActiveRecord::Migration[8.0]
  def change
    create_table :casts do |t|
      t.string :name, null: false
      t.string :image_key, null: true
      t.string :cast_type, null: false

      t.timestamps
    end
  end
end
