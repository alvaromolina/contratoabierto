json.array!(@contract_budget_items) do |contract_budget_item|
  json.extract! contract_budget_item, :id, :contract_id, :budget_item_id, :description, :contract_number, :unit_price, :quantity_type, :quntity, :total, :origin
  json.url contract_budget_item_url(contract_budget_item, format: :json)
end
