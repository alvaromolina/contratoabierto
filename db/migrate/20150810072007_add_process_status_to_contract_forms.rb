class AddProcessStatusToContractForms < ActiveRecord::Migration
  def change
    add_column :contract_forms, :process_status, :string
  end
end
