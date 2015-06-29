json.array!(@contracts) do |contract|
  json.extract! contract, :id, :origin_id, :entity_id, :mode_id, :control_number, :publication_number, :description, :status_id, :contracted_amount_cents, :contracted_amount_currency, :publication_date, :presentation_date, :contact, :warranty, :specification_price, :aclaration_date, :granted_date, :abandonment_date, :region_id, :regulation_id
  json.url contract_url(contract, format: :json)
end
