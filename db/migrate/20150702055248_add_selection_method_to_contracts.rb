class AddSelectionMethodToContracts < ActiveRecord::Migration
  def change
    add_reference :contracts, :selection_method, index: true
    add_reference :contracts, :awarding_type, index: true
    add_reference :contracts, :contract_type, index: true
    add_column :contracts, :warranty_asked, :string
    add_column :contracts, :currency_contract, :string
  end
end