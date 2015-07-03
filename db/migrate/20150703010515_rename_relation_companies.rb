class RenameRelationCompanies < ActiveRecord::Migration
  def change
  	rename_column :relation_companies, :company_parent_id, :parent_company_id
  	add_column :contracted_companies, :contract_number, :string
  	add_column :contracted_companies, :contract_date, :datetime
  	add_column :contracted_companies, :contract_amount, :decimal
  	add_column :contracts, :specified_amount, :decimal

  end
end
