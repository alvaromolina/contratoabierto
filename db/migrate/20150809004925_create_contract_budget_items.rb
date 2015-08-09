class CreateContractBudgetItems < ActiveRecord::Migration
  def change
    create_table :contract_budget_items do |t|
      t.references :contract, index: true
      t.references :budget_item, index: true
      t.text :description
      t.string :contract_number
      t.decimal :unit_price
      t.string :quantity_type
      t.decimal :quntity
      t.decimal :total
      t.string :origin

      t.timestamps
    end
  end
end
