class CompanyReportsGrid

  include Datagrid

  scope do
    Company.where('(select count(1) from contracted_companies where contracted_companies.company_id = companies.id) > 0')
  end

  filter(:name, :string, :header => "Nombre empresa:") { |value| where("name ilike '%#{value}%'") }

  column(:name, :header => "Nombre") do |model|
    format(model.name) do |value|
      link_to value, model
    end
  end


  column(:count, :header => "#Contratos", :order => "(select count(1) from contracted_companies where contracted_companies.company_id = companies.id)") do |record|
    record.contracted_companies.count
  end

  column(:count, :header => "#Aplicaciones") do |record|
    record.applying_companies.count
  end

  column(:sum, :header => "Monto contratos", :order => "(select sum(local_amount) from contracted_companies where contracted_companies.company_id = companies.id)") do |record|
    record.contracted_companies.sum(:local_amount)
  end


end
