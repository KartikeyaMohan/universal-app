class CreateMovieImages < ActiveRecord::Migration[8.0]
  def change
    create_table :movie_images do |t|
      t.references :movie, null: false, foreign_key: true
      t.string :image_key
      
      t.timestamps
    end
  end
end
