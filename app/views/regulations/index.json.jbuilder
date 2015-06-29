json.array!(@regulations) do |regulation|
  json.extract! regulation, :id, :name
  json.url regulation_url(regulation, format: :json)
end
