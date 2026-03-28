class AddCapturedAtToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :captured_at, :datetime
  end
end
