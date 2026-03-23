class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.string :name, null: false
      t.string :hero_image_key, null: true
      t.decimal :rating, precision: 3, scale: 2, null: true

      t.timestamps
    end
  end
end
