json.array!(@contracted__companies) do |contracted__company|
  json.extract! contracted__company, :id
  json.url contracted__company_url(contracted__company, format: :json)
end
