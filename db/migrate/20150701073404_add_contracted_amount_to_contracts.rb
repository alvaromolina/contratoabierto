class AddContractedAmountToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :contracted_amount, :decimal
  end
end
