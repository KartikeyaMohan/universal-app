class CreateMovieDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :movie_details do |t|
      t.references :movie, null: false, foreign_key: true
      t.string :trailer_key, null: true
      t.text :description, null: true
      
      t.timestamps
    end
  end
end
