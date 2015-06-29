class AddOriginCodeToMode < ActiveRecord::Migration
  def change
    add_column :modes, :origin_code, :string
  end
end
