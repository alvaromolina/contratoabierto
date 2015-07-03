class CreateContractedCompanies < ActiveRecord::Migration
  def change
    create_table :contracted_companies do |t|
      t.references :contracts, index: true
      t.references :companies, index: true

      t.timestamps
    end
  end
end
