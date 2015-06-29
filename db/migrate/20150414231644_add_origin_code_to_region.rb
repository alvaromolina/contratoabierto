class AddOriginCodeToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :origin_code, :string
  end
end
