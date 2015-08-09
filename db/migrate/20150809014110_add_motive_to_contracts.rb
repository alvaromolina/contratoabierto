class AddMotiveToContracts < ActiveRecord::Migration
  def change
    add_reference :contracts, :motive, index: true
  end
end
