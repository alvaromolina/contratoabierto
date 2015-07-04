class AddCompanyOriginToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :company_origin, :string
  end
end
