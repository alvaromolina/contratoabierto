class AddOriginCodeToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :origin_code, :string
  end
end
