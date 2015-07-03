class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :company_type
      t.string :document_type
      t.string :document_number

      t.timestamps
    end
  end
end
