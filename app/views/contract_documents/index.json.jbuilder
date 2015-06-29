json.array!(@contract_documents) do |contract_document|
  json.extract! contract_document, :id, :contract_id, :name, :link
  json.url contract_document_url(contract_document, format: :json)
end
