class ChangeQuantityName < ActiveRecord::Migration
  def change
  	rename_column :contract_budget_items, :quntity, :quantity
  end
end
