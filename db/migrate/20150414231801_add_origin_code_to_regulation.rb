class AddOriginCodeToRegulation < ActiveRecord::Migration
  def change
    add_column :regulations, :origin_code, :string
  end
end
