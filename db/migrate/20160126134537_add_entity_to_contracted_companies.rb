class AddEntityToContractedCompanies < ActiveRecord::Migration
  def change
    add_reference :contracted_companies, :entity, index: true
    add_reference :applying_companies, :entity, index: true

  end
end
