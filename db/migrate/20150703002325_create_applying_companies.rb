class CreateApplyingCompanies < ActiveRecord::Migration
  def change
    create_table :applying_companies do |t|
      t.references :contracts, index: true
      t.references :companies, index: true

      t.timestamps
    end
  end
end
