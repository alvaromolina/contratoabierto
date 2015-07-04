class AddIndexToContractFormsName < ActiveRecord::Migration
  def change
  	add_index :contract_forms, :name
  end
end
