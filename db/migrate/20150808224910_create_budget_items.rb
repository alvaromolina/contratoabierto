class CreateBudgetItems < ActiveRecord::Migration
  def change
    create_table :budget_items do |t|
      t.string :origin_number
      t.string :item_number
      t.string :name

      t.timestamps
    end
  end
end
