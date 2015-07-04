class RenameApplyingCompanies < ActiveRecord::Migration
  def change
  	rename_column :applying_companies, :companies_id, :company_id
  	rename_column :applying_companies, :contracts_id, :contract_id
  	rename_column :contracted_companies, :contracts_id, :contract_id
  	rename_column :contracted_companies, :companies_id, :company_id

  end
end
