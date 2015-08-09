class ContractBudgetItem < ActiveRecord::Base
  belongs_to :contract
  belongs_to :budget_item
end
