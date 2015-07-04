json.array!(@applying_companies) do |applying_company|
  json.extract! applying_company, :id
  json.url applying_company_url(applying_company, format: :json)
end
