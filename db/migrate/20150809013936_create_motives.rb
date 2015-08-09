class CreateMotives < ActiveRecord::Migration
  def change
    create_table :motives do |t|
      t.string :name

      t.timestamps
    end
  end
end
