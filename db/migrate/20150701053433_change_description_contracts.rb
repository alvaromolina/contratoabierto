class ChangeDescriptionContracts < ActiveRecord::Migration
  def change
  	 change_column :contracts, :description, :text
  end
end
