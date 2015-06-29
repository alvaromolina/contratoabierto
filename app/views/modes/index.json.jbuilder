json.array!(@modes) do |mode|
  json.extract! mode, :id, :name
  json.url mode_url(mode, format: :json)
end
