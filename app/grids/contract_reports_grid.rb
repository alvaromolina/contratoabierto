class ContractReportsGrid

  include Datagrid

  scope do
    Contract
  end


  filter(:description, :string, :header => "Descripción:",) { |value| where("description ilike '%#{value}%'") }

  filter(:publication_date, :date, :range => true,  :header => "Fecha publicacion:")

  filter(:status_id, :enum, :header => "Estado:",  :select => proc { Status.all.order(:name).map {|c| [c.name, c.id] } }, :multiple => true)

  filter(:origin_id, :string, :header => "Nro:",) { |value| where("origin_id ilike '#{value}%'") }

  filter(:entity_id, :enum, :header => "Entidad:", :select => Entity.all.order(:name).map {|c| [c.name, c.id] })

  column(:origin_id, :header => "Nro") do |model|
    format(model.origin_id) do |value|
      link_to value, model
    end
  end
  column(:description, :header => "Objeto")
  column(:entity, :header => "Entidad") do |record|
    record.entity.name
  end
  column(:status, :header => "Estado") do |record|
    record.status.name
  end
  column(:publication_date, :header => "Fecha publicación") do |model|
    model.created_at.to_date
  end
  column(:contracted_amount, :header => "Monto contrato (BS)")
  column(:region, :header => "Region") do |record|
    record.region.name
  end
  column(:mode, :header => "Modalidad") do |record|
    record.mode.name
  end
end
