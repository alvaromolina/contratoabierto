class CreateContractForms < ActiveRecord::Migration
  def change
    create_table :contract_forms do |t|
      t.references :contract, index: true
      t.string :name
      t.string :link

      t.timestamps
    end
  end
end
