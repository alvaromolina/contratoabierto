class IndexDateContracts < ActiveRecord::Migration
  def change
  	add_index :contracts, :publication_date
   	add_index :contracts, :description
  end
end
