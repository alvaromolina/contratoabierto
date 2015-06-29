class CreateRegulations < ActiveRecord::Migration
  def change
    create_table :regulations do |t|
      t.string :name

      t.timestamps
    end
  end
end
