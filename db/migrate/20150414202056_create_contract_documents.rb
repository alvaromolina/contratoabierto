class CreateContractDocuments < ActiveRecord::Migration
  def change
    create_table :contract_documents do |t|
      t.references :contract, index: true
      t.string :name
      t.string :link

      t.timestamps
    end
  end
end
