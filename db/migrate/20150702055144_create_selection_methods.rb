class CreateSelectionMethods < ActiveRecord::Migration
  def change
    create_table :selection_methods do |t|
      t.string :name

      t.timestamps
    end
  end
end
