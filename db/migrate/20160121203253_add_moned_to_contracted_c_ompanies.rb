class AddMonedToContractedCOmpanies < ActiveRecord::Migration
  def change
 	add_column :contracted_companies, :currency, :string
 	add_column :contracted_companies, :exchange, :decimal

  end
end
