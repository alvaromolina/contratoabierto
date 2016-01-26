class BudgetItemReportsGrid

  include Datagrid

  scope do
    ContractBudgetItem
  end

  filter(:id, :integer, :header => "Id contrato:")
  filter(:contract_date, :date, :range => true, :header => "Fecha contrato:")
  filter(:budget_item_id, :enum, :header => "Item presupuesto:", :select => BudgetItem.all.order(:name).map {|c| [c.name, c.id] })
  filter(:description, :string, :header => "Sub-item:") { |value| where("upper(description) ilike '%#{value.upcase}%'") }

  column(:contract_id, :header => "Nro") do |model|
    format(model.contract) do |value|
      link_to value.origin_id, value
    end
  end
  
  column(:contract_id, :header => "Feha") do |record|
    record.contract.publication_date ? record.contract.publication_date.to_date : ''
  end

  column(:contract_id, :header => "Contrato") do |record|
    record.contract.description
  end
  column(:budget_item, :header => "Sub-item") do |record|
    record.budget_item.name
  end
  column(:contract_id, :header => "Sub-item") do |record|
    record.description
  end

  column(:unit_price, :header => "Precio unidad")
  column(:quantity_type, :header => "Tipo unidad")
  column(:quantity, :header => "Cantidad")
  column(:total, :header => "Total")


end
