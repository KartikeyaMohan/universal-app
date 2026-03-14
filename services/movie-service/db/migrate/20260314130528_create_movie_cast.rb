class CreateMovieCast < ActiveRecord::Migration[8.0]
  def change
    create_table :movie_casts do |t|
      t.references :movie, null: false, foreign_key: true
      t.string :name, null: false
      t.string :image_key, null: true
      
      t.timestamps
    end
  end
end
