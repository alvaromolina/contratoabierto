class AddLocalAmountToContractedCompanies < ActiveRecord::Migration
  def change
    add_column :contracted_companies, :local_amount, :decimal
  end
end
