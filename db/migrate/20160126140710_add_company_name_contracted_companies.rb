class AddCompanyNameContractedCompanies < ActiveRecord::Migration
  def change
    add_column :contracted_companies, :company_name, :string
    add_column :applying_companies, :company_name, :string

  end
end
