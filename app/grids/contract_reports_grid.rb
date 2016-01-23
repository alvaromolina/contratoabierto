class ContractReportsGrid

  include Datagrid

  scope do
    Contract
  end

  filter(:description, :string, :header => "Objeto:")
  filter(:publication_date, :date, :range => true,  :header => "Fecha publicación:")
  filter(:status_id, :enum, :header => "Estado:", :select => proc { Status.all.order(:name).map {|c| [c.name, c.id] }}, :multiple => true)
  filter(:entity_id, :enum, :header => "Entidad:", :select => proc { Entity.all.order(:name).map {|c| [c.name, c.id] }}, :multiple => true)


  column(:origin_id, :header => "CUCE")
  column(:description, :header => "Objeto")
  column(:entity, :header => "Entidad") do |record|
    record.entity.name
  end
  column(:status, :header => "Estado") do |record|
    record.entity.name
  end
  column(:publication_date, :header => "Fecha publicación") do |model|
    model.created_at.to_date
  end
  column(:contracted_amount, :header => "Monto contrato (BS)")
  column(:region, :header => "Region") do |record|
    record.region.name
  end
  column(:mode, :header => "Region") do |record|
    record.mode.name
  end
end
