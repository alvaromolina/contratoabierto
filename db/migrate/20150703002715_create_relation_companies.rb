class CreateRelationCompanies < ActiveRecord::Migration
  def change
    create_table :relation_companies do |t|
      t.integer :company_parent_id
      t.integer :children_company_id

      t.timestamps
    end
  end
end
