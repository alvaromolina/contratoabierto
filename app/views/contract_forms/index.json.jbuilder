json.array!(@contract_forms) do |contract_form|
  json.extract! contract_form, :id, :contract_id, :name, :link
  json.url contract_form_url(contract_form, format: :json)
end
