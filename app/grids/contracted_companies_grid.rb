class ContractedCompaniesGrid

  include Datagrid

  scope do
    ContractedCompany
  end

  filter(:id, :integer, :header => "Id contrato:")
  filter(:contract_date, :date, :range => true, :header => "Fecha contrato:")
  filter(:entity_id, :enum, :header => "Entidad:", :select => Entity.all.order(:name).map {|c| [c.name, c.id] })
  filter(:company_name, :string, :header => "Empresa:") { |value| where("company_name ilike '%#{value}%'") }

  column(:contract, :header => "Nro") do |record|
    record.contract.origin_id
  end
  column(:contract_date, :header => "Feha contrato") do |record|
    record.contract_date.to_date
  end

  column(:company, :header => "Compañia") do |record|
    record.company.name
  end

  column(:company, :header => "Tipo Compañia") do |record|
    record.company.company_type
  end

  column(:contract, :header => "Contrato") do |record|
    record.contract.description
  end

  column(:local_amount, :header => "Monto contratado")


  column(:contract, :header => "Entidad") do |record|
    record.contract.entity.name
  end


end
