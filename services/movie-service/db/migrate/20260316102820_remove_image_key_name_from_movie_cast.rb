class RemoveImageKeyNameFromMovieCast < ActiveRecord::Migration[8.0]
  def change
    remove_column :movie_casts, :image_key, :string
    remove_column :movie_casts, :name, :string
  end
end
