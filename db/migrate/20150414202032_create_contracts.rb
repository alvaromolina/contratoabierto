class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :origin_id
      t.references :entity, index: true
      t.references :mode, index: true
      t.string :control_number
      t.integer :publication_number
      t.string :description
      t.references :status, index: true
      t.integer :contracted_amount_cents
      t.string :contracted_amount_currency
      t.date :publication_date
      t.date :presentation_date
      t.string :contact
      t.string :warranty
      t.string :specification_price
      t.datetime :aclaration_date
      t.date :granted_date
      t.date :abandonment_date
      t.references :region, index: true
      t.references :regulation, index: true

      t.timestamps
    end
  end
end
